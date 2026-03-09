#!/bin/bash
# permissions_test.sh - Unit tests for the permissions hook script
#
# Usage: ./permissions_test.sh
#
# Tests glob matching, command splitting, deny/allow behavior, and
# whitespace trimming in the PreToolUse permissions hook.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PERMISSIONS_SCRIPT="$SCRIPT_DIR/../bundle/.claude/hooks/permissions.sh"
TEST_PASSED=0
TEST_FAILED=0

# =============================================================================
# Test Utilities
# =============================================================================

assert_equals() {
  local expected="$1"
  local actual="$2"
  local message="${3:-}"

  if [ "$expected" = "$actual" ]; then
    echo "  ✓ PASS: $message"
    ((++TEST_PASSED))
  else
    echo "  ✗ FAIL: $message"
    echo "    Expected: '$expected'"
    echo "    Actual:   '$actual'"
    ((++TEST_FAILED))
  fi
}

assert_return_code() {
  local expected="$1"
  local actual="$2"
  local message="${3:-}"

  if [ "$expected" -eq "$actual" ]; then
    echo "  ✓ PASS: $message"
    ((++TEST_PASSED))
  else
    echo "  ✗ FAIL: $message"
    echo "    Expected return code: $expected"
    echo "    Actual return code:   $actual"
    ((++TEST_FAILED))
  fi
}

# =============================================================================
# Test Setup
# =============================================================================

TEST_TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_TMP_DIR"' EXIT
mkdir -p "$TEST_TMP_DIR/.claude"

create_settings() {
  local allow_json="$1"
  local deny_json="$2"
  cat > "$TEST_TMP_DIR/.claude/settings.json" <<EOF
{
  "permissions": {
    "allow": $allow_json,
    "deny": $deny_json
  }
}
EOF
}

# Run permissions.sh with a given command, using temp HOME for settings.
# Stderr is captured to $TEST_TMP_DIR/stderr.
run_permissions() {
  local command="$1"
  jq -n --arg cmd "$command" '{"tool_input": {"command": $cmd}}' | \
    HOME="$TEST_TMP_DIR" /bin/bash "$PERMISSIONS_SCRIPT" 2>"$TEST_TMP_DIR/stderr"
}

stderr_contains() {
  grep -q "$1" "$TEST_TMP_DIR/stderr" && echo "yes" || echo "no"
}

# =============================================================================
# Test Cases
# =============================================================================

test_wildcard_allow_patterns() {
  echo "Testing wildcard allow patterns..."
  create_settings '["Bash(ls:*)"]' '[]'

  local rc
  run_permissions "ls -al" && rc=0 || rc=$?
  assert_return_code 0 "$rc" "ls -al allowed by Bash(ls:*)"

  run_permissions "ls" && rc=0 || rc=$?
  assert_return_code 0 "$rc" "bare ls allowed by Bash(ls:*)"

}

test_wildcard_deny_patterns() {
  echo "Testing wildcard deny patterns..."
  create_settings '["Bash(ls:*)"]' '["Bash(sudo:*)"]'

  local rc
  run_permissions "sudo rm -rf /" && rc=0 || rc=$?
  assert_return_code 2 "$rc" "sudo rm -rf / blocked"
  assert_equals "yes" "$(stderr_contains 'Denied')" \
    "sudo rm -rf / denied via wildcard (stderr contains Denied)"
}

test_exact_deny_patterns() {
  echo "Testing exact deny patterns..."
  create_settings '["Bash(rm:*)"]' '["Bash(rm -rf /)"]'

  local rc
  run_permissions "rm -rf /" && rc=0 || rc=$?
  assert_return_code 2 "$rc" "rm -rf / blocked by exact deny"
  assert_equals "yes" "$(stderr_contains 'Denied')" \
    "rm -rf / denied via exact pattern (stderr contains Denied)"

  run_permissions "rm foo.txt" && rc=0 || rc=$?
  assert_return_code 0 "$rc" "rm foo.txt allowed (not matched by exact deny)"
}

test_pipe_splitting() {
  echo "Testing pipe command splitting..."
  create_settings '["Bash(ls:*)", "Bash(head:*)"]' '[]'

  local rc
  run_permissions "ls -al | head" && rc=0 || rc=$?
  assert_return_code 0 "$rc" "ls -al | head allowed when both parts match"

}

test_semicolon_splitting() {
  echo "Testing semicolon command splitting..."
  create_settings '["Bash(ls:*)", "Bash(pwd:*)"]' '[]'

  local rc
  run_permissions "ls; pwd" && rc=0 || rc=$?
  assert_return_code 0 "$rc" "ls; pwd allowed when both parts match"
}

test_and_splitting() {
  echo "Testing && command splitting..."
  create_settings '["Bash(ls:*)", "Bash(pwd:*)"]' '[]'

  local rc
  run_permissions "ls && pwd" && rc=0 || rc=$?
  assert_return_code 0 "$rc" "ls && pwd allowed when both parts match"
}

test_or_splitting() {
  echo "Testing || command splitting..."
  create_settings '["Bash(ls:*)", "Bash(pwd:*)"]' '[]'

  local rc
  run_permissions "ls || pwd" && rc=0 || rc=$?
  assert_return_code 0 "$rc" "ls || pwd allowed when both parts match"
}

test_whitespace_trimming() {
  echo "Testing whitespace trimming..."
  create_settings '["Bash(ls:*)", "Bash(head:*)"]' '[]'

  local rc
  # After splitting "ls -al | head", subcommands have surrounding spaces
  # that must be trimmed for pattern matching to work
  run_permissions "ls -al | head" && rc=0 || rc=$?
  assert_return_code 0 "$rc" "pipe-split commands have whitespace trimmed"
}

test_deny_before_allow() {
  echo "Testing deny evaluated before allow..."
  # sudo:* in both deny and allow — deny should win
  create_settings '["Bash(sudo:*)"]' '["Bash(sudo:*)"]'

  local rc
  run_permissions "sudo ls" && rc=0 || rc=$?
  assert_return_code 2 "$rc" "denied even when also in allow list"
  assert_equals "yes" "$(stderr_contains 'Denied')" \
    "deny takes precedence over allow (stderr contains Denied)"
}

test_pattern_conversion() {
  echo "Testing :* to * pattern conversion..."
  create_settings '["Bash(npm run:*)"]' '[]'

  local rc
  run_permissions "npm run build" && rc=0 || rc=$?
  assert_return_code 0 "$rc" "npm run build matches Bash(npm run:*)"

}

test_pipe_with_complex_commands() {
  echo "Testing pipe with complex commands..."
  create_settings '["Bash(ls:*)", "Bash(awk:*)", "Bash(head:*)"]' '[]'

  local rc
  run_permissions "ls -al | awk '{print \$3, \$9}'" && rc=0 || rc=$?
  assert_return_code 0 "$rc" "ls -al | awk allowed with both in allow list"

  run_permissions "ls -al | head" && rc=0 || rc=$?
  assert_return_code 0 "$rc" "ls -al | head allowed with both in allow list"
}

# =============================================================================
# Run Tests
# =============================================================================

echo ""
echo "Running permissions hook tests..."
echo "================================="
echo ""

test_wildcard_allow_patterns
test_wildcard_deny_patterns
test_exact_deny_patterns
test_pipe_splitting
test_semicolon_splitting
test_and_splitting
test_or_splitting
test_whitespace_trimming
test_deny_before_allow
test_pattern_conversion
test_pipe_with_complex_commands

echo ""
echo "================================="
echo "Results: $TEST_PASSED passed, $TEST_FAILED failed"
echo ""

if [ "$TEST_FAILED" -gt 0 ]; then
  exit 1
fi

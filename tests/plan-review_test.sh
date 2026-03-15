#!/bin/bash
# plan-review_test.sh - Unit tests for the plan-review hook script
#
# Usage: ./tests/plan-review_test.sh
#
# Tests per-session state management, codex review flow,
# deny/allow behavior, and fail-open guarantees.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAN_REVIEW_SCRIPT="$SCRIPT_DIR/../bundle/.claude/hooks/plan-review.sh"
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

# Create a mock codex command
MOCK_BIN="$TEST_TMP_DIR/bin"
mkdir -p "$MOCK_BIN"

# Default mock codex: outputs VERDICT: APPROVED
set_mock_codex_approved() {
  cat > "$MOCK_BIN/codex" <<'MOCK'
#!/bin/bash
echo "Looks good. VERDICT: APPROVED"
MOCK
  chmod +x "$MOCK_BIN/codex"
}

set_mock_codex_revise() {
  cat > "$MOCK_BIN/codex" <<'MOCK'
#!/bin/bash
echo "Issue found. Please fix X. VERDICT: REVISE"
MOCK
  chmod +x "$MOCK_BIN/codex"
}

set_mock_codex_fail() {
  cat > "$MOCK_BIN/codex" <<'MOCK'
#!/bin/bash
exit 1
MOCK
  chmod +x "$MOCK_BIN/codex"
}

set_mock_codex_multiline() {
  cat > "$MOCK_BIN/codex" <<'MOCK'
#!/bin/bash
printf 'Line 1: issue with "quotes"\nLine 2: another problem\nLine 3: conclusion\nVERDICT: REVISE'
MOCK
  chmod +x "$MOCK_BIN/codex"
}

# Start with default (APPROVED)
set_mock_codex_approved

# Helper: create a project dir with .claude for each test
setup_project() {
  local project_dir="$TEST_TMP_DIR/project_$$_$RANDOM"
  mkdir -p "$project_dir/.claude"
  mkdir -p "$TEST_TMP_DIR/home/.claude/logs"
  echo "$project_dir"
}

# Helper: create a state file for a session
create_state_file() {
  local project_dir="$1"
  local session_id="$2"
  local file_path="$3"
  local reviews="${4:-0}"
  local state_dir="$project_dir/.claude/plan-review"
  mkdir -p "$state_dir"
  jq -n \
    --arg fp "$file_path" \
    --argjson rev "$reviews" \
    --argjson ts "$(date +%s)" \
    '{file_path: $fp, reviews: $rev, timestamp: $ts}' > "$state_dir/${session_id}.json"
}

# Helper: run plan-review.sh with given JSON input
run_plan_review() {
  local input="$1"
  local project_dir="${2:-}"
  local env_vars=""

  if [ -n "$project_dir" ]; then
    env_vars="CLAUDE_PROJECT_DIR=$project_dir"
  fi

  env -i PATH="$MOCK_BIN:/usr/bin:/bin:/usr/sbin:/sbin" \
    HOME="$TEST_TMP_DIR/home" \
    ${env_vars:+$env_vars} \
    /bin/bash "$PLAN_REVIEW_SCRIPT" <<< "$input"
}

# =============================================================================
# Test Cases
# =============================================================================

# Case 1: CLAUDE_PROJECT_DIR unset → exit 0
test_no_project_dir() {
  echo "Test 1: CLAUDE_PROJECT_DIR unset..."

  local rc output
  output=$(run_plan_review '{}') && rc=0 || rc=$?
  assert_return_code 0 "$rc" "exits 0 when CLAUDE_PROJECT_DIR is unset"
}

# Case 2: permission_mode != plan → exit 0
test_non_plan_mode() {
  echo "Test 2: permission_mode != plan..."

  local project_dir
  project_dir=$(setup_project)
  local input
  input=$(jq -nc '{
    permission_mode: "default",
    session_id: "test-sess",
    hook_event_name: "PreToolUse",
    tool_name: "Write"
  }')

  local rc output
  output=$(run_plan_review "$input" "$project_dir") && rc=0 || rc=$?
  assert_return_code 0 "$rc" "exits 0 when permission_mode is not plan"
}

# Case 3: PostToolUse + file_path present → state file created, exit 0
test_post_tool_with_file_path() {
  echo "Test 3: PostToolUse + file_path present..."

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-with-fp"
  local input
  input=$(jq -nc \
    --arg sid "$session_id" \
    '{
      permission_mode: "plan",
      session_id: $sid,
      hook_event_name: "PostToolUse",
      tool_name: "Write",
      tool_input: {file_path: "/tmp/plan.md"}
    }')

  local rc output
  output=$(run_plan_review "$input" "$project_dir") && rc=0 || rc=$?
  assert_return_code 0 "$rc" "exits 0 with file_path present"

  local state_file="$project_dir/.claude/plan-review/${session_id}.json"
  assert_equals "yes" "$([ -f "$state_file" ] && echo yes || echo no)" \
    "state file created"
  assert_equals "/tmp/plan.md" "$(jq -r '.file_path' "$state_file")" \
    "state file contains correct file_path"
  assert_equals "0" "$(jq -r '.reviews' "$state_file")" \
    "state file reviews is 0"
}

# Case 4: PostToolUse + file_path absent → state file NOT created, exit 0
test_post_tool_no_file_path() {
  echo "Test 4: PostToolUse + no file_path..."

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-no-fp"
  local input
  input=$(jq -nc \
    --arg sid "$session_id" \
    '{
      permission_mode: "plan",
      session_id: $sid,
      hook_event_name: "PostToolUse",
      tool_name: "Write",
      tool_input: {}
    }')

  local rc output
  output=$(run_plan_review "$input" "$project_dir") && rc=0 || rc=$?
  assert_return_code 0 "$rc" "exits 0 when file_path is absent"

  local state_file="$project_dir/.claude/plan-review/${session_id}.json"
  assert_equals "no" "$([ -f "$state_file" ] && echo yes || echo no)" \
    "state file NOT created"
}

# Case 5: ExitPlanMode + untracked session → exit 0
test_exit_plan_untracked() {
  echo "Test 5: ExitPlanMode + untracked session..."

  local project_dir
  project_dir=$(setup_project)
  local input
  input=$(jq -nc '{
    permission_mode: "plan",
    session_id: "sess-untracked",
    hook_event_name: "PreToolUse",
    tool_name: "ExitPlanMode",
    tool_input: {}
  }')

  local rc output
  output=$(run_plan_review "$input" "$project_dir") && rc=0 || rc=$?
  assert_return_code 0 "$rc" "exits 0 for untracked session ExitPlanMode"
}

# Case 6: ExitPlanMode + APPROVED → exit 0, reviews incremented
test_exit_plan_approved() {
  echo "Test 6: ExitPlanMode + APPROVED..."
  set_mock_codex_approved

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-approved"
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 0

  local input
  input=$(jq -nc \
    --arg sid "$session_id" \
    '{
      permission_mode: "plan",
      session_id: $sid,
      hook_event_name: "PreToolUse",
      tool_name: "ExitPlanMode",
      tool_input: {}
    }')

  local rc output
  output=$(run_plan_review "$input" "$project_dir") && rc=0 || rc=$?
  assert_return_code 0 "$rc" "exits 0 when APPROVED"
  assert_equals "" "$output" "no deny JSON output"

  local state_file="$project_dir/.claude/plan-review/${session_id}.json"
  assert_equals "1" "$(jq -r '.reviews' "$state_file")" \
    "reviews incremented to 1"
}

# Case 7: ExitPlanMode + REVISE → deny JSON output, reviews incremented
test_exit_plan_revise() {
  echo "Test 7: ExitPlanMode + REVISE..."
  set_mock_codex_revise

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-revise"
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 0

  local input
  input=$(jq -nc \
    --arg sid "$session_id" \
    '{
      permission_mode: "plan",
      session_id: $sid,
      hook_event_name: "PreToolUse",
      tool_name: "ExitPlanMode",
      tool_input: {}
    }')

  local rc output
  output=$(run_plan_review "$input" "$project_dir") && rc=0 || rc=$?
  assert_return_code 0 "$rc" "exits 0 (deny is via JSON, not exit code)"

  # Validate deny JSON shape
  assert_equals "deny" "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision')" \
    "permissionDecision is deny"
  assert_equals "PreToolUse" "$(echo "$output" | jq -r '.hookSpecificOutput.hookEventName')" \
    "hookEventName present"
  local has_reason
  has_reason=$(echo "$output" | jq -e '.hookSpecificOutput.permissionDecisionReason' > /dev/null 2>&1 && echo yes || echo no)
  assert_equals "yes" "$has_reason" "permissionDecisionReason present"

  # Validate backtick path (not Markdown link)
  local reason
  reason=$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecisionReason')
  local has_backtick
  has_backtick=$(echo "$reason" | grep -q '`/tmp/plan.md`' && echo yes || echo no)
  assert_equals "yes" "$has_backtick" "file_path wrapped in backticks"

  local state_file="$project_dir/.claude/plan-review/${session_id}.json"
  assert_equals "1" "$(jq -r '.reviews' "$state_file")" \
    "reviews incremented to 1"
}

# Case 8: reviews=3 → exit 0 (skip review)
test_review_cap() {
  echo "Test 8: reviews=3 cap..."
  set_mock_codex_revise  # should NOT be called

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-capped"
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 3

  local input
  input=$(jq -nc \
    --arg sid "$session_id" \
    '{
      permission_mode: "plan",
      session_id: $sid,
      hook_event_name: "PreToolUse",
      tool_name: "ExitPlanMode",
      tool_input: {}
    }')

  local rc output
  output=$(run_plan_review "$input" "$project_dir") && rc=0 || rc=$?
  assert_return_code 0 "$rc" "exits 0 at review cap"
  assert_equals "" "$output" "no output when capped"
}

# Case 9: codex failure (exit 1) → treated as deny
test_codex_failure() {
  echo "Test 9: codex failure..."
  set_mock_codex_fail

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-codex-fail"
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 0

  local input
  input=$(jq -nc \
    --arg sid "$session_id" \
    '{
      permission_mode: "plan",
      session_id: $sid,
      hook_event_name: "PreToolUse",
      tool_name: "ExitPlanMode",
      tool_input: {}
    }')

  local rc output
  output=$(run_plan_review "$input" "$project_dir") && rc=0 || rc=$?
  assert_return_code 0 "$rc" "exits 0 even on codex failure"

  assert_equals "deny" "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision')" \
    "codex failure treated as deny"
}

# Case 10: file_path with spaces and special characters
test_special_chars_in_path() {
  echo "Test 10: file_path with spaces and special chars..."
  set_mock_codex_revise

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-special"
  local special_path="/tmp/my plan (v2).md"
  create_state_file "$project_dir" "$session_id" "$special_path" 0

  local input
  input=$(jq -nc \
    --arg sid "$session_id" \
    '{
      permission_mode: "plan",
      session_id: $sid,
      hook_event_name: "PreToolUse",
      tool_name: "ExitPlanMode",
      tool_input: {}
    }')

  local rc output
  output=$(run_plan_review "$input" "$project_dir") && rc=0 || rc=$?
  assert_return_code 0 "$rc" "exits 0 with special chars"

  # Verify output is valid JSON
  local valid_json
  valid_json=$(echo "$output" | jq -e '.' > /dev/null 2>&1 && echo yes || echo no)
  assert_equals "yes" "$valid_json" "output is valid JSON"

  # Verify path with special chars in reason
  local reason
  reason=$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecisionReason')
  local has_path
  has_path=$(echo "$reason" | grep -qF "$special_path" && echo yes || echo no)
  assert_equals "yes" "$has_path" "special path preserved in reason"
}

# Case 11: multiline review_results → deny JSON is valid
test_multiline_review() {
  echo "Test 11: multiline review_results..."
  set_mock_codex_multiline

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-multiline"
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 0

  local input
  input=$(jq -nc \
    --arg sid "$session_id" \
    '{
      permission_mode: "plan",
      session_id: $sid,
      hook_event_name: "PreToolUse",
      tool_name: "ExitPlanMode",
      tool_input: {}
    }')

  local rc output
  output=$(run_plan_review "$input" "$project_dir") && rc=0 || rc=$?
  assert_return_code 0 "$rc" "exits 0 with multiline review"

  local valid_json
  valid_json=$(echo "$output" | jq -e '.' > /dev/null 2>&1 && echo yes || echo no)
  assert_equals "yes" "$valid_json" "multiline output is valid JSON"

  assert_equals "deny" "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision')" \
    "multiline review treated as deny"
}

# Case 12: state file corrupted → exit 0 (fail-open)
test_corrupted_state() {
  echo "Test 12: corrupted state file..."
  set_mock_codex_approved

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-corrupted"
  local state_dir="$project_dir/.claude/plan-review"
  mkdir -p "$state_dir"
  echo "not valid json{{{" > "$state_dir/${session_id}.json"

  local input
  input=$(jq -nc \
    --arg sid "$session_id" \
    '{
      permission_mode: "plan",
      session_id: $sid,
      hook_event_name: "PreToolUse",
      tool_name: "ExitPlanMode",
      tool_input: {}
    }')

  local rc output
  output=$(run_plan_review "$input" "$project_dir") && rc=0 || rc=$?
  assert_return_code 0 "$rc" "exits 0 with corrupted state (fail-open)"
}

# =============================================================================
# Run Tests
# =============================================================================

echo ""
echo "Running plan-review hook tests..."
echo "================================="
echo ""

test_no_project_dir
test_non_plan_mode
test_post_tool_with_file_path
test_post_tool_no_file_path
test_exit_plan_untracked
test_exit_plan_approved
test_exit_plan_revise
test_review_cap
test_codex_failure
test_special_chars_in_path
test_multiline_review
test_corrupted_state

echo ""
echo "================================="
echo "Results: $TEST_PASSED passed, $TEST_FAILED failed"
echo ""

if [ "$TEST_FAILED" -gt 0 ]; then
  exit 1
fi

#!/bin/bash
# layout_test.sh - Unit tests for the layout script
#
# Usage: ./layout_test.sh
#
# Demonstrates how to test the refactored layout script by:
# 1. Sourcing the script (doesn't run main due to BASH_SOURCE check)
# 2. Overriding wrapper functions with mocks
# 3. Testing individual functions in isolation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_PASSED=0
TEST_FAILED=0

# =============================================================================
# Test Utilities
# =============================================================================

setup_test_env() {
  TEST_TMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TEST_TMP_DIR"' EXIT
}

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
# Source the script (won't run main due to BASH_SOURCE check)
# =============================================================================

source "$SCRIPT_DIR/../bundle/.tmux/layout"

# =============================================================================
# Mock Functions
# =============================================================================

MOCK_TMUX_CALLS=()
MOCK_PANE_ID_COUNTER=0

_tmux() {
  MOCK_TMUX_CALLS+=("$*")

  case "$1" in
    display-message)
      echo "%0"
      ;;
    split-window)
      ((MOCK_PANE_ID_COUNTER++))
      echo "%$MOCK_PANE_ID_COUNTER"
      ;;
    send-keys)
      # Just record the call
      ;;
  esac
}

_realpath() {
  echo "$1"
}

_read_choice() {
  echo "${MOCK_USER_CHOICE:-1}"
}

# =============================================================================
# Test Cases
# =============================================================================

test_validate_split_direction() {
  echo "Testing validate_split_direction..."

  local rc

  validate_split_direction "vertical" 0 2>/dev/null && rc=0 || rc=$?
  assert_return_code 0 "$rc" "vertical is valid"

  validate_split_direction "horizontal" 0 2>/dev/null && rc=0 || rc=$?
  assert_return_code 0 "$rc" "horizontal is valid"

  validate_split_direction "invalid" 0 2>/dev/null && rc=0 || rc=$?
  assert_return_code 1 "$rc" "invalid direction returns error"
}

test_validate_pane_count() {
  echo "Testing validate_pane_count..."

  local rc

  validate_pane_count 3 "test.json" 2>/dev/null && rc=0 || rc=$?
  assert_return_code 0 "$rc" "non-zero count is valid"

  validate_pane_count 0 "test.json" 2>/dev/null && rc=0 || rc=$?
  assert_return_code 1 "$rc" "zero count returns error"
}

test_check_dependencies() {
  echo "Testing check_dependencies..."

  local rc

  # jq should be available in test environment
  check_dependencies 2>/dev/null && rc=0 || rc=$?
  assert_return_code 0 "$rc" "passes when jq is installed"
}

test_check_tmux_session() {
  echo "Testing check_tmux_session..."

  local rc

  # Test without TMUX env var
  local old_tmux="${TMUX:-}"
  unset TMUX
  check_tmux_session 2>/dev/null && rc=0 || rc=$?
  assert_return_code 1 "$rc" "fails outside tmux"

  # Restore and test with TMUX set
  TMUX="/tmp/tmux-test"
  check_tmux_session 2>/dev/null && rc=0 || rc=$?
  assert_return_code 0 "$rc" "passes inside tmux"

  # Restore original
  if [ -n "$old_tmux" ]; then
    TMUX="$old_tmux"
  else
    unset TMUX
  fi
}

test_get_current_pane_id() {
  echo "Testing get_current_pane_id..."

  MOCK_TMUX_CALLS=()
  local result
  result=$(get_current_pane_id)

  assert_equals "%0" "$result" "returns mock pane ID"
  # Note: subshell doesn't persist array changes to parent, just verify the result
}

test_create_pane() {
  echo "Testing create_pane..."

  MOCK_TMUX_CALLS=()
  MOCK_PANE_ID_COUNTER=0

  local result
  result=$(create_pane "%0" "vertical" "20%")

  assert_equals "%1" "$result" "returns new pane ID"
}

test_send_command_to_pane() {
  echo "Testing send_command_to_pane..."

  # Test that the function calls _tmux with correct args
  # We capture the call directly since it doesn't return output
  local captured_call=""
  _tmux() {
    captured_call="$*"
  }

  send_command_to_pane "%1" "echo hello"

  assert_equals "send-keys -t %1 echo hello C-m" "$captured_call" "sends command correctly"

  # Restore original mock
  _tmux() {
    MOCK_TMUX_CALLS+=("$*")
    case "$1" in
      display-message) echo "%0" ;;
      split-window) ((MOCK_PANE_ID_COUNTER++)); echo "%$MOCK_PANE_ID_COUNTER" ;;
    esac
  }
}

test_create_panes_from_json() {
  echo "Testing create_panes_from_json..."

  setup_test_env

  # Create test JSON
  cat > "$TEST_TMP_DIR/test.json" << 'EOF'
{
  "panes": [
    { "commands": ["cd /tmp"] },
    { "split": "vertical", "size": "30%" },
    { "split": "horizontal" }
  ]
}
EOF

  # Use file-based counter for subshell persistence
  local counter_file="$TEST_TMP_DIR/counter"
  echo "0" > "$counter_file"

  _tmux() {
    case "$1" in
      display-message) echo "%0" ;;
      split-window)
        local n
        n=$(cat "$counter_file")
        ((++n))
        echo "$n" > "$counter_file"
        echo "%$n"
        ;;
    esac
  }

  # Override _jq to use real jq
  _jq() { jq "$@"; }

  local -a pane_ids=()
  while IFS= read -r pane_id; do
    [ -n "$pane_id" ] && pane_ids+=("$pane_id")
  done < <(create_panes_from_json "$TEST_TMP_DIR/test.json")

  assert_equals 3 "${#pane_ids[@]}" "creates correct number of panes"
  assert_equals "%0" "${pane_ids[0]}" "first pane is current pane"
  assert_equals "%1" "${pane_ids[1]}" "second pane created"
  assert_equals "%2" "${pane_ids[2]}" "third pane created"
}

test_select_json_file_interactive() {
  echo "Testing select_json_file_interactive..."

  local rc result

  MOCK_USER_CHOICE="2"
  result=$(select_json_file_interactive "file1.json|/path/file1.json" "file2.json|/path/file2.json" 2>/dev/null) && rc=0 || rc=$?
  assert_equals "/path/file2.json" "$result" "selects correct file"

  MOCK_USER_CHOICE="q"
  result=$(select_json_file_interactive "file1.json|/path/file1.json" 2>/dev/null) && rc=0 || rc=$?
  assert_equals "" "$result" "returns empty on cancel"

  MOCK_USER_CHOICE="99"
  result=$(select_json_file_interactive "file1.json|/path/file1.json" 2>/dev/null) && rc=0 || rc=$?
  assert_return_code 1 "$rc" "invalid selection returns error"
}

test_resolve_json_file() {
  echo "Testing resolve_json_file..."

  setup_test_env

  local rc result

  # Test with existing file
  cat > "$TEST_TMP_DIR/layout.json" << 'EOF'
{"panes": []}
EOF

  result=$(resolve_json_file "$TEST_TMP_DIR/layout.json" 2>/dev/null) && rc=0 || rc=$?
  assert_return_code 0 "$rc" "returns success for existing file"
  assert_equals "$TEST_TMP_DIR/layout.json" "$result" "returns the file path"

  # Test with non-existing file
  result=$(resolve_json_file "/nonexistent/file.json" 2>/dev/null) && rc=0 || rc=$?
  assert_return_code 1 "$rc" "returns error for non-existing file"
}

test_json_parsing_functions() {
  echo "Testing JSON parsing functions..."

  setup_test_env

  # Create test JSON
  cat > "$TEST_TMP_DIR/test.json" << 'EOF'
{
  "panes": [
    { "commands": ["pwd", "ls -la"] },
    { "split": "horizontal", "size": "40%", "commands": ["echo test"] },
    { "split": "vertical" }
  ]
}
EOF

  # Use real jq for parsing tests
  _jq() { jq "$@"; }

  local result

  # Test get_pane_count
  result=$(get_pane_count "$TEST_TMP_DIR/test.json")
  assert_equals "3" "$result" "get_pane_count returns correct count"

  # Test get_pane_split
  result=$(get_pane_split "$TEST_TMP_DIR/test.json" 0)
  assert_equals "vertical" "$result" "get_pane_split returns default for missing split"

  result=$(get_pane_split "$TEST_TMP_DIR/test.json" 1)
  assert_equals "horizontal" "$result" "get_pane_split returns explicit split"

  # Test get_pane_size
  result=$(get_pane_size "$TEST_TMP_DIR/test.json" 0)
  assert_equals "" "$result" "get_pane_size returns empty for missing size"

  result=$(get_pane_size "$TEST_TMP_DIR/test.json" 1)
  assert_equals "40%" "$result" "get_pane_size returns explicit size"

  # Test get_pane_command_count
  result=$(get_pane_command_count "$TEST_TMP_DIR/test.json" 0)
  assert_equals "2" "$result" "get_pane_command_count returns correct count"

  result=$(get_pane_command_count "$TEST_TMP_DIR/test.json" 2)
  assert_equals "0" "$result" "get_pane_command_count returns 0 for empty commands"

  # Test get_pane_command
  result=$(get_pane_command "$TEST_TMP_DIR/test.json" 0 0)
  assert_equals "pwd" "$result" "get_pane_command returns first command"

  result=$(get_pane_command "$TEST_TMP_DIR/test.json" 0 1)
  assert_equals "ls -la" "$result" "get_pane_command returns second command"
}

test_execute_pane_commands() {
  echo "Testing execute_pane_commands..."

  setup_test_env

  # Create test JSON
  cat > "$TEST_TMP_DIR/test.json" << 'EOF'
{
  "panes": [
    { "commands": ["cmd1", "cmd2"] },
    { "commands": ["cmd3"] }
  ]
}
EOF

  # Capture tmux calls: _tmux send-keys -t $pane_id $command C-m
  # Arguments: $1=send-keys, $2=-t, $3=pane_id, $4=command, $5=C-m
  local -a captured_commands=()
  _tmux() {
    if [ "$1" = "send-keys" ]; then
      captured_commands+=("$4")  # The command is the 4th argument
    fi
  }
  _jq() { jq "$@"; }

  execute_pane_commands "$TEST_TMP_DIR/test.json" "%0" "%1"

  assert_equals 3 "${#captured_commands[@]}" "executes correct number of commands"
  assert_equals "cmd1" "${captured_commands[0]}" "first command sent"
  assert_equals "cmd2" "${captured_commands[1]}" "second command sent"
  assert_equals "cmd3" "${captured_commands[2]}" "third command sent"
}

# =============================================================================
# Run Tests
# =============================================================================

echo ""
echo "Running layout script tests..."
echo "=============================="
echo ""

test_check_dependencies
test_check_tmux_session
test_validate_split_direction
test_validate_pane_count
test_get_current_pane_id
test_create_pane
test_send_command_to_pane
test_create_panes_from_json
test_select_json_file_interactive
test_resolve_json_file
test_json_parsing_functions
test_execute_pane_commands

echo ""
echo "=============================="
echo "Results: $TEST_PASSED passed, $TEST_FAILED failed"
echo ""

if [ "$TEST_FAILED" -gt 0 ]; then
  exit 1
fi

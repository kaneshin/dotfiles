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

# Default mock codex: outputs JSONL with VERDICT: APPROVED
set_mock_codex_approved() {
  cat > "$MOCK_BIN/codex" <<'MOCK'
#!/bin/bash
printf '%s ' "$@" | tr '\n' ' ' >> "$HOME/.claude/logs/codex-argv.log"
printf '\n' >> "$HOME/.claude/logs/codex-argv.log"
echo '{"type":"thread.started","thread_id":"mock-thread-001"}'
echo '{"type":"turn.started"}'
echo '{"type":"item.completed","item":{"id":"item_0","type":"agent_message","text":"Looks good. VERDICT: APPROVED"}}'
echo '{"type":"turn.completed","usage":{}}'
MOCK
  chmod +x "$MOCK_BIN/codex"
}

set_mock_codex_revise() {
  cat > "$MOCK_BIN/codex" <<'MOCK'
#!/bin/bash
printf '%s ' "$@" | tr '\n' ' ' >> "$HOME/.claude/logs/codex-argv.log"
printf '\n' >> "$HOME/.claude/logs/codex-argv.log"
echo '{"type":"thread.started","thread_id":"mock-thread-002"}'
echo '{"type":"turn.started"}'
echo '{"type":"item.completed","item":{"id":"item_0","type":"agent_message","text":"Issue found. Please fix X. VERDICT: REVISE"}}'
echo '{"type":"turn.completed","usage":{}}'
MOCK
  chmod +x "$MOCK_BIN/codex"
}

set_mock_codex_fail() {
  cat > "$MOCK_BIN/codex" <<'MOCK'
#!/bin/bash
printf '%s ' "$@" | tr '\n' ' ' >> "$HOME/.claude/logs/codex-argv.log"
printf '\n' >> "$HOME/.claude/logs/codex-argv.log"
exit 1
MOCK
  chmod +x "$MOCK_BIN/codex"
}

set_mock_codex_multiline() {
  cat > "$MOCK_BIN/codex" <<'MOCK'
#!/bin/bash
printf '%s ' "$@" | tr '\n' ' ' >> "$HOME/.claude/logs/codex-argv.log"
printf '\n' >> "$HOME/.claude/logs/codex-argv.log"
echo '{"type":"thread.started","thread_id":"mock-thread-003"}'
echo '{"type":"turn.started"}'
printf '{"type":"item.completed","item":{"id":"item_0","type":"agent_message","text":"Line 1: issue with \\"quotes\\"\\nLine 2: another problem"}}\n'
printf '{"type":"item.completed","item":{"id":"item_1","type":"agent_message","text":"Line 3: conclusion\\nVERDICT: REVISE"}}\n'
echo '{"type":"turn.completed","usage":{}}'
MOCK
  chmod +x "$MOCK_BIN/codex"
}

set_mock_codex_resume_fail() {
  cat > "$MOCK_BIN/codex" <<'MOCK'
#!/bin/bash
printf '%s ' "$@" | tr '\n' ' ' >> "$HOME/.claude/logs/codex-argv.log"
printf '\n' >> "$HOME/.claude/logs/codex-argv.log"
if [ "$1" = "exec" ] && [ "$2" = "resume" ]; then
  exit 1
fi
echo '{"type":"thread.started","thread_id":"mock-thread-fresh"}'
echo '{"type":"turn.started"}'
echo '{"type":"item.completed","item":{"id":"item_0","type":"agent_message","text":"Fresh review. VERDICT: REVISE"}}'
echo '{"type":"turn.completed","usage":{}}'
MOCK
  chmod +x "$MOCK_BIN/codex"
}

set_mock_codex_resume_partial() {
  cat > "$MOCK_BIN/codex" <<'MOCK'
#!/bin/bash
printf '%s ' "$@" | tr '\n' ' ' >> "$HOME/.claude/logs/codex-argv.log"
printf '\n' >> "$HOME/.claude/logs/codex-argv.log"
if [ "$1" = "exec" ] && [ "$2" = "resume" ]; then
  echo '{"type":"thread.started","thread_id":"mock-thread-partial"}'
  exit 1
fi
echo '{"type":"thread.started","thread_id":"mock-thread-fresh-after-partial"}'
echo '{"type":"turn.started"}'
echo '{"type":"item.completed","item":{"id":"item_0","type":"agent_message","text":"Fresh after partial. VERDICT: REVISE"}}'
echo '{"type":"turn.completed","usage":{}}'
MOCK
  chmod +x "$MOCK_BIN/codex"
}

# Ensure codex argv log directory exists
mkdir -p "$TEST_TMP_DIR/home/.claude/logs"
: > "$TEST_TMP_DIR/home/.claude/logs/codex-argv.log"

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
# Args: project_dir session_id file_path [reviews [thread_id [model]]]
create_state_file() {
  local project_dir="$1"
  local session_id="$2"
  local file_path="$3"
  local reviews="${4:-0}"
  local thread_id="${5:-}"
  local model="${6:-}"
  local state_dir="$project_dir/.claude/plan-review"
  mkdir -p "$state_dir"
  if [ -n "$thread_id" ] && [ -n "$model" ]; then
    jq -n \
      --arg fp "$file_path" \
      --argjson rev "$reviews" \
      --argjson ts "$(date +%s)" \
      --arg tid "$thread_id" \
      --arg model "$model" \
      '{file_path: $fp, reviews: $rev, timestamp: $ts, thread_id: $tid, model: $model}' > "$state_dir/${session_id}.json"
  elif [ -n "$thread_id" ]; then
    jq -n \
      --arg fp "$file_path" \
      --argjson rev "$reviews" \
      --argjson ts "$(date +%s)" \
      --arg tid "$thread_id" \
      '{file_path: $fp, reviews: $rev, timestamp: $ts, thread_id: $tid}' > "$state_dir/${session_id}.json"
  else
    jq -n \
      --arg fp "$file_path" \
      --argjson rev "$reviews" \
      --argjson ts "$(date +%s)" \
      '{file_path: $fp, reviews: $rev, timestamp: $ts}' > "$state_dir/${session_id}.json"
  fi
}

# Helper: run plan-review.sh with given JSON input
run_plan_review() {
  local input="$1"
  local project_dir="${2:-}"
  local env_vars=""

  # Clear codex argv log before each run
  : > "$TEST_TMP_DIR/home/.claude/logs/codex-argv.log"

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
  assert_equals "null" "$(jq -r '.thread_id // "null"' "$state_file")" \
    "thread_id cleared after APPROVED"

  local argv_log="$TEST_TMP_DIR/home/.claude/logs/codex-argv.log"
  local has_exec_json
  has_exec_json=$(grep -q 'exec --json' "$argv_log" && echo yes || echo no)
  assert_equals "yes" "$has_exec_json" "codex called with exec --json"
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
  assert_equals "mock-thread-002" "$(jq -r '.thread_id // "null"' "$state_file")" \
    "thread_id saved after REVISE"
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

  local state_file="$project_dir/.claude/plan-review/${session_id}.json"
  assert_equals "null" "$(jq -r '.thread_id // "null"' "$state_file")" \
    "thread_id not saved on failure"
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

# Case 13: Resume flow — state has codex_thread_id, verify resume argv
test_resume_flow() {
  echo "Test 13: Resume flow..."
  set_mock_codex_revise

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-resume"
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 1 "existing-thread-abc" "gpt-5.4"

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
  assert_return_code 0 "$rc" "exits 0 on resume"

  local argv_log="$TEST_TMP_DIR/home/.claude/logs/codex-argv.log"
  local has_resume
  has_resume=$(grep -q 'exec resume --json existing-thread-abc' "$argv_log" && echo yes || echo no)
  assert_equals "yes" "$has_resume" "codex called with exec resume --json <thread_id>"
}

# Case 14: Resume failure retry — resume exits 1, falls back to fresh exec
test_resume_failure_retry() {
  echo "Test 14: Resume failure retry..."
  set_mock_codex_resume_fail

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-resume-fail"
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 1 "old-thread-xyz" "gpt-5.4"

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
  assert_return_code 0 "$rc" "exits 0 after retry"

  local argv_log="$TEST_TMP_DIR/home/.claude/logs/codex-argv.log"
  local line_count
  line_count=$(wc -l < "$argv_log" | tr -d ' ')
  assert_equals "2" "$line_count" "codex called twice (resume then fresh exec)"

  local state_file="$project_dir/.claude/plan-review/${session_id}.json"
  assert_equals "mock-thread-fresh" "$(jq -r '.thread_id // "null"' "$state_file")" \
    "thread_id updated from fresh exec"
}

# Case 15: Resume partial output — resume emits thread.started then exits 1
test_resume_partial_output() {
  echo "Test 15: Resume partial output..."
  set_mock_codex_resume_partial

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-resume-partial"
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 1 "old-thread-partial"

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
  assert_return_code 0 "$rc" "exits 0 after partial resume retry"

  local state_file="$project_dir/.claude/plan-review/${session_id}.json"
  assert_equals "mock-thread-fresh-after-partial" "$(jq -r '.thread_id // "null"' "$state_file")" \
    "thread_id updated from fresh exec after partial"
}

# Case 16: thread_id preserved across update_plan_review_file for same file_path
test_thread_id_preserved_same_path() {
  echo "Test 16: thread_id preserved for same file_path..."

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-preserve-tid"
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 1 "preserved-thread-123"

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
  assert_return_code 0 "$rc" "exits 0"

  local state_file="$project_dir/.claude/plan-review/${session_id}.json"
  assert_equals "preserved-thread-123" "$(jq -r '.thread_id // "null"' "$state_file")" \
    "thread_id preserved for same file_path"
  assert_equals "1" "$(jq -r '.reviews' "$state_file")" \
    "reviews preserved for same file_path"
}

# Case 17: File path change resets state
test_file_path_change_resets() {
  echo "Test 17: File path change resets state..."

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-path-change"
  create_state_file "$project_dir" "$session_id" "/tmp/old-plan.md" 2 "old-thread-999"

  local input
  input=$(jq -nc \
    --arg sid "$session_id" \
    '{
      permission_mode: "plan",
      session_id: $sid,
      hook_event_name: "PostToolUse",
      tool_name: "Write",
      tool_input: {file_path: "/tmp/new-plan.md"}
    }')

  local rc output
  output=$(run_plan_review "$input" "$project_dir") && rc=0 || rc=$?
  assert_return_code 0 "$rc" "exits 0"

  local state_file="$project_dir/.claude/plan-review/${session_id}.json"
  assert_equals "/tmp/new-plan.md" "$(jq -r '.file_path' "$state_file")" \
    "file_path updated"
  assert_equals "0" "$(jq -r '.reviews' "$state_file")" \
    "reviews reset to 0"
  assert_equals "null" "$(jq -r '.thread_id // "null"' "$state_file")" \
    "thread_id cleared on file_path change"
}

# Case 18: Resume without thread.started — text returned but no new thread_id
test_resume_no_thread_started() {
  echo "Test 18: Resume without thread.started..."

  # Mock that returns text but no thread.started event
  cat > "$MOCK_BIN/codex" <<'MOCK'
#!/bin/bash
printf '%s ' "$@" | tr '\n' ' ' >> "$HOME/.claude/logs/codex-argv.log"
printf '\n' >> "$HOME/.claude/logs/codex-argv.log"
echo '{"type":"turn.started"}'
echo '{"type":"item.completed","item":{"id":"item_0","type":"agent_message","text":"Review without thread. VERDICT: REVISE"}}'
echo '{"type":"turn.completed","usage":{}}'
MOCK
  chmod +x "$MOCK_BIN/codex"

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-no-thread-started"
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 1 "existing-thread-keep"

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
  assert_return_code 0 "$rc" "exits 0"

  # thread_id should NOT be overwritten since REVIEW_THREAD_ID is empty
  local state_file="$project_dir/.claude/plan-review/${session_id}.json"
  assert_equals "existing-thread-keep" "$(jq -r '.thread_id // "null"' "$state_file")" \
    "existing thread_id preserved when no thread.started"
}

# Case 19: Corrupted state during resume — fail-open
test_corrupted_state_resume() {
  echo "Test 19: Corrupted state during resume..."
  set_mock_codex_approved

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-corrupt-resume"
  local state_dir="$project_dir/.claude/plan-review"
  mkdir -p "$state_dir"
  echo '{"file_path":"/tmp/plan.md","reviews":0,"codex_thread_id":"corrupt-tid"' > "$state_dir/${session_id}.json"

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
  assert_return_code 0 "$rc" "exits 0 with corrupted state during resume (fail-open)"
}

# =============================================================================
# Config / Settings Tests (Cases 20–29)
# =============================================================================

# Helper: write a settings.json to a given directory
write_settings() {
  local dir="$1"
  local json="$2"
  mkdir -p "$dir"
  echo "$json" > "$dir/settings.json"
}

# Case 20: No planReview key anywhere → defaults in log
test_config_defaults() {
  echo "Test 20: Config defaults (no planReview anywhere)..."
  set_mock_codex_approved

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-cfg-defaults"
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 0

  local input
  input=$(jq -nc --arg sid "$session_id" '{
    permission_mode: "plan",
    session_id: $sid,
    hook_event_name: "PreToolUse",
    tool_name: "ExitPlanMode",
    tool_input: {}
  }')

  run_plan_review "$input" "$project_dir" > /dev/null

  local log_line
  log_line=$(grep 'settings:' "$TEST_TMP_DIR/home/.claude/logs/plan-review.log" | tail -1)
  local has_defaults
  has_defaults=$(echo "$log_line" | grep -q 'max=3 min=1 model=gpt-5.4' && echo yes || echo no)
  assert_equals "yes" "$has_defaults" "defaults logged: max=3 min=1 model=gpt-5.4"
}

# Case 21: Global maxReviews:1 → cap fires after 1 attempt
test_config_global_maxreviews() {
  echo "Test 21: Global maxReviews:1 caps at 1..."
  set_mock_codex_revise

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-cfg-maxrev"
  # reviews already at 1 — should be capped
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 1

  write_settings "$TEST_TMP_DIR/home/.claude" '{"planReview":{"maxReviews":1}}'

  local input
  input=$(jq -nc --arg sid "$session_id" '{
    permission_mode: "plan",
    session_id: $sid,
    hook_event_name: "PreToolUse",
    tool_name: "ExitPlanMode",
    tool_input: {}
  }')

  local rc output
  output=$(run_plan_review "$input" "$project_dir") && rc=0 || rc=$?
  assert_return_code 0 "$rc" "exits 0 at cap"
  assert_equals "" "$output" "no output when capped at maxReviews=1"

  # Restore default global settings (no planReview)
  rm -f "$TEST_TMP_DIR/home/.claude/settings.json"
}

# Case 22: Project settings override global value
test_config_project_override() {
  echo "Test 22: Project settings override global..."
  set_mock_codex_revise

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-cfg-proj"
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 0

  # Global says max=1, project overrides to max=5
  write_settings "$TEST_TMP_DIR/home/.claude" '{"planReview":{"maxReviews":1}}'
  write_settings "$project_dir/.claude" '{"planReview":{"maxReviews":5}}'

  local input
  input=$(jq -nc --arg sid "$session_id" '{
    permission_mode: "plan",
    session_id: $sid,
    hook_event_name: "PreToolUse",
    tool_name: "ExitPlanMode",
    tool_input: {}
  }')

  local rc output
  output=$(run_plan_review "$input" "$project_dir") && rc=0 || rc=$?
  assert_return_code 0 "$rc" "exits 0"

  local log_line
  log_line=$(grep 'settings:' "$TEST_TMP_DIR/home/.claude/logs/plan-review.log" | tail -1)
  local has_max5
  has_max5=$(echo "$log_line" | grep -q 'max=5' && echo yes || echo no)
  assert_equals "yes" "$has_max5" "project overrides global: max=5"

  rm -f "$TEST_TMP_DIR/home/.claude/settings.json"
  rm -f "$project_dir/.claude/settings.json"
}

# Case 23: Local settings override project value
test_config_local_override() {
  echo "Test 23: Local settings override project..."
  set_mock_codex_revise

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-cfg-local"
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 0

  write_settings "$project_dir/.claude" '{"planReview":{"model":"gpt-4o"}}'
  echo '{"planReview":{"model":"gpt-local"}}' > "$project_dir/.claude/settings.local.json"

  local input
  input=$(jq -nc --arg sid "$session_id" '{
    permission_mode: "plan",
    session_id: $sid,
    hook_event_name: "PreToolUse",
    tool_name: "ExitPlanMode",
    tool_input: {}
  }')

  run_plan_review "$input" "$project_dir" > /dev/null

  local log_line
  log_line=$(grep 'settings:' "$TEST_TMP_DIR/home/.claude/logs/plan-review.log" | tail -1)
  local has_local_model
  has_local_model=$(echo "$log_line" | grep -q 'model=gpt-local' && echo yes || echo no)
  assert_equals "yes" "$has_local_model" "local overrides project: model=gpt-local"

  rm -f "$project_dir/.claude/settings.json" "$project_dir/.claude/settings.local.json"
}

# Case 24: Malformed project JSON → global value preserved
test_config_malformed_project_skipped() {
  echo "Test 24: Malformed project JSON skipped..."
  set_mock_codex_approved

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-cfg-malformed"
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 0

  write_settings "$TEST_TMP_DIR/home/.claude" '{"planReview":{"maxReviews":2}}'
  echo '{invalid json' > "$project_dir/.claude/settings.json"

  local input
  input=$(jq -nc --arg sid "$session_id" '{
    permission_mode: "plan",
    session_id: $sid,
    hook_event_name: "PreToolUse",
    tool_name: "ExitPlanMode",
    tool_input: {}
  }')

  run_plan_review "$input" "$project_dir" > /dev/null

  local log_line
  log_line=$(grep 'settings:' "$TEST_TMP_DIR/home/.claude/logs/plan-review.log" | tail -1)
  local has_max2
  has_max2=$(echo "$log_line" | grep -q 'max=2' && echo yes || echo no)
  assert_equals "yes" "$has_max2" "malformed project JSON skipped; global max=2 preserved"

  rm -f "$TEST_TMP_DIR/home/.claude/settings.json"
  rm -f "$project_dir/.claude/settings.json"
}

# Case 25: maxReviews:1, minReviews:3 → effective max raised to 3
test_config_max_min_normalization() {
  echo "Test 25: maxReviews < minReviews → normalized up..."
  set_mock_codex_approved

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-cfg-normalize"
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 0

  write_settings "$project_dir/.claude" '{"planReview":{"maxReviews":1,"minReviews":3}}'

  local input
  input=$(jq -nc --arg sid "$session_id" '{
    permission_mode: "plan",
    session_id: $sid,
    hook_event_name: "PreToolUse",
    tool_name: "ExitPlanMode",
    tool_input: {}
  }')

  run_plan_review "$input" "$project_dir" > /dev/null

  local log_line
  log_line=$(grep 'settings:' "$TEST_TMP_DIR/home/.claude/logs/plan-review.log" | tail -1)
  local has_max3
  has_max3=$(echo "$log_line" | grep -q 'max=3' && echo yes || echo no)
  assert_equals "yes" "$has_max3" "maxReviews normalized up to minReviews=3"

  rm -f "$project_dir/.claude/settings.json"
}

# Case 26: minReviews:2, first APPROVED (reviews=1) → deny with 1/2 message
test_config_min_reviews_gates_approved() {
  echo "Test 26: minReviews:2, first APPROVED denied..."
  set_mock_codex_approved

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-cfg-min-gate"
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 0

  write_settings "$project_dir/.claude" '{"planReview":{"minReviews":2}}'

  local input
  input=$(jq -nc --arg sid "$session_id" '{
    permission_mode: "plan",
    session_id: $sid,
    hook_event_name: "PreToolUse",
    tool_name: "ExitPlanMode",
    tool_input: {}
  }')

  local rc output
  output=$(run_plan_review "$input" "$project_dir") && rc=0 || rc=$?
  assert_return_code 0 "$rc" "exits 0"

  # Should deny because reviews(1) < minReviews(2)
  assert_equals "deny" "$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecision')" \
    "first APPROVED denied when reviews < minReviews"

  local reason
  reason=$(echo "$output" | jq -r '.hookSpecificOutput.permissionDecisionReason')
  local has_count
  has_count=$(echo "$reason" | grep -q '1/2' && echo yes || echo no)
  assert_equals "yes" "$has_count" "reason contains 1/2 count"

  rm -f "$project_dir/.claude/settings.json"
}

# Case 27: minReviews:2, second APPROVED (reviews=2) → allow
test_config_min_reviews_second_approved() {
  echo "Test 27: minReviews:2, second APPROVED allowed..."
  set_mock_codex_approved

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-cfg-min-pass"
  # reviews already at 1 from previous attempt; this will be incremented to 2
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 1

  write_settings "$project_dir/.claude" '{"planReview":{"minReviews":2}}'

  local input
  input=$(jq -nc --arg sid "$session_id" '{
    permission_mode: "plan",
    session_id: $sid,
    hook_event_name: "PreToolUse",
    tool_name: "ExitPlanMode",
    tool_input: {}
  }')

  local rc output
  output=$(run_plan_review "$input" "$project_dir") && rc=0 || rc=$?
  assert_return_code 0 "$rc" "exits 0"
  assert_equals "" "$output" "second APPROVED allowed (no deny output)"

  rm -f "$project_dir/.claude/settings.json"
}

# Case 28: Thread has codex_model:"old", config is "new" → fresh exec used
test_config_model_change_clears_thread() {
  echo "Test 28: Model change clears thread..."

  # Mock that records argv and returns REVISE; we check no 'resume' call
  cat > "$MOCK_BIN/codex" <<'MOCK'
#!/bin/bash
printf '%s ' "$@" | tr '\n' ' ' >> "$HOME/.claude/logs/codex-argv.log"
printf '\n' >> "$HOME/.claude/logs/codex-argv.log"
echo '{"type":"thread.started","thread_id":"mock-thread-new-model"}'
echo '{"type":"turn.started"}'
echo '{"type":"item.completed","item":{"id":"item_0","type":"agent_message","text":"Fresh review. VERDICT: REVISE"}}'
echo '{"type":"turn.completed","usage":{}}'
MOCK
  chmod +x "$MOCK_BIN/codex"

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-cfg-model-change"
  # State has old model; config will have new model
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 1 "old-thread-id" "old-model"

  write_settings "$project_dir/.claude" '{"planReview":{"model":"new-model"}}'

  local input
  input=$(jq -nc --arg sid "$session_id" '{
    permission_mode: "plan",
    session_id: $sid,
    hook_event_name: "PreToolUse",
    tool_name: "ExitPlanMode",
    tool_input: {}
  }')

  run_plan_review "$input" "$project_dir" > /dev/null

  local argv_log="$TEST_TMP_DIR/home/.claude/logs/codex-argv.log"
  local has_resume
  has_resume=$(grep -q 'resume' "$argv_log" && echo yes || echo no)
  assert_equals "no" "$has_resume" "resume NOT called after model change"

  local has_fresh
  has_fresh=$(grep -q 'exec --json' "$argv_log" && echo yes || echo no)
  assert_equals "yes" "$has_fresh" "fresh exec called with new model"

  rm -f "$project_dir/.claude/settings.json"
}

# Case 29: After REVISE, codex_model saved alongside codex_thread_id
test_config_codex_model_persisted() {
  echo "Test 29: codex_model persisted alongside codex_thread_id on REVISE..."
  set_mock_codex_revise

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-cfg-model-persist"
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 0

  write_settings "$project_dir/.claude" '{"planReview":{"model":"gpt-persist-test"}}'

  local input
  input=$(jq -nc --arg sid "$session_id" '{
    permission_mode: "plan",
    session_id: $sid,
    hook_event_name: "PreToolUse",
    tool_name: "ExitPlanMode",
    tool_input: {}
  }')

  run_plan_review "$input" "$project_dir" > /dev/null

  local state_file="$project_dir/.claude/plan-review/${session_id}.json"
  assert_equals "mock-thread-002" "$(jq -r '.thread_id // "null"' "$state_file")" \
    "thread_id persisted"
  assert_equals "gpt-persist-test" "$(jq -r '.model // "null"' "$state_file")" \
    "model persisted alongside thread_id"

  rm -f "$project_dir/.claude/settings.json"
}

# =============================================================================
# Pre-refactoring coverage tests (Cases 30–32)
# =============================================================================

# Case 30: State mutation failure — read-only state file → fail-open (exit 0)
test_state_mutation_failure() {
  echo "Test 30: State mutation failure (read-only state file)..."
  set_mock_codex_approved

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-readonly"
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 0

  # Make state file read-only so jq writes fail
  chmod 444 "$project_dir/.claude/plan-review/${session_id}.json"

  local input
  input=$(jq -nc --arg sid "$session_id" '{
    permission_mode: "plan",
    session_id: $sid,
    hook_event_name: "PreToolUse",
    tool_name: "ExitPlanMode",
    tool_input: {}
  }')

  local rc output
  output=$(run_plan_review "$input" "$project_dir") && rc=0 || rc=$?
  assert_return_code 0 "$rc" "exits 0 when state file is read-only (fail-open)"

  # Restore permissions for cleanup
  chmod 644 "$project_dir/.claude/plan-review/${session_id}.json"
}

# Case 31: Atomic codex_thread_id preservation — PostToolUse for same plan file
test_thread_id_atomic_preservation() {
  echo "Test 31: Atomic codex_thread_id preservation on PostToolUse..."

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-atomic-tid"
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 2 "atomic-thread-456" "gpt-5.4"

  local input
  input=$(jq -nc --arg sid "$session_id" '{
    permission_mode: "plan",
    session_id: $sid,
    hook_event_name: "PostToolUse",
    tool_name: "Write",
    tool_input: {file_path: "/tmp/plan.md"}
  }')

  local rc output
  output=$(run_plan_review "$input" "$project_dir") && rc=0 || rc=$?
  assert_return_code 0 "$rc" "exits 0"

  local state_file="$project_dir/.claude/plan-review/${session_id}.json"
  # Verify state file exists and is valid JSON
  local valid_json
  valid_json=$(jq -e '.' "$state_file" > /dev/null 2>&1 && echo yes || echo no)
  assert_equals "yes" "$valid_json" "state file is valid JSON after PostToolUse"

  # thread_id must be preserved immediately after the hook runs
  assert_equals "atomic-thread-456" "$(jq -r '.thread_id // "null"' "$state_file")" \
    "thread_id preserved atomically on disk"
  assert_equals "2" "$(jq -r '.reviews' "$state_file")" \
    "reviews count preserved"
  assert_equals "gpt-5.4" "$(jq -r '.model // "null"' "$state_file")" \
    "model preserved"
}

# Case 32: Log output format — verify expected header line in plan-review.log
test_log_output_format() {
  echo "Test 32: Log output format..."
  set_mock_codex_approved

  local project_dir
  project_dir=$(setup_project)
  local session_id="sess-log-fmt"
  create_state_file "$project_dir" "$session_id" "/tmp/plan.md" 0

  # Clear the log before this test
  : > "$TEST_TMP_DIR/home/.claude/logs/plan-review.log"

  local input
  input=$(jq -nc --arg sid "$session_id" '{
    permission_mode: "plan",
    session_id: $sid,
    hook_event_name: "PreToolUse",
    tool_name: "ExitPlanMode",
    tool_input: {}
  }')

  run_plan_review "$input" "$project_dir" > /dev/null

  local log_file="$TEST_TMP_DIR/home/.claude/logs/plan-review.log"
  # Verify the expected header format: === <date> <event> (<tool>) hook executed ===
  local has_header
  has_header=$(grep -qE '^=== [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} PreToolUse \(ExitPlanMode\) hook executed ===$' \
    "$log_file" && echo yes || echo no)
  assert_equals "yes" "$has_header" "log contains expected header format"
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
test_resume_flow
test_resume_failure_retry
test_resume_partial_output
test_thread_id_preserved_same_path
test_file_path_change_resets
test_resume_no_thread_started
test_corrupted_state_resume
test_config_defaults
test_config_global_maxreviews
test_config_project_override
test_config_local_override
test_config_malformed_project_skipped
test_config_max_min_normalization
test_config_min_reviews_gates_approved
test_config_min_reviews_second_approved
test_config_model_change_clears_thread
test_config_codex_model_persisted
test_state_mutation_failure
test_thread_id_atomic_preservation
test_log_output_format

echo ""
echo "================================="
echo "Results: $TEST_PASSED passed, $TEST_FAILED failed"
echo ""

if [ "$TEST_FAILED" -gt 0 ]; then
  exit 1
fi

#!/bin/bash

# Plan review hook — runs an external review (codex CLI) when ExitPlanMode is invoked.
# State is stored per-session in .claude/plan-review/<session_id>.json.

# This hook only operates within a project directory.
if [ -z "$CLAUDE_PROJECT_DIR" ]; then
  exit 0
fi

cd "$CLAUDE_PROJECT_DIR"

INPUT=$(cat)
PERMISSION_MODE=$(echo "$INPUT" | jq -r '.permission_mode // empty')
if [ "$PERMISSION_MODE" != "plan" ]; then
  exit 0
fi

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
HOOK_EVENT_NAME=$(echo "$INPUT" | jq -r '.hook_event_name // empty')
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Logging
LOG_DIR="$HOME/.claude/logs"
[ ! -d "$LOG_DIR" ] && mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/plan-review.log"
log() { echo "$1" >> "$LOG_FILE"; }
log "=== $(date '+%Y-%m-%d %H:%M:%S') $HOOK_EVENT_NAME ($TOOL_NAME) hook executed ==="

# Per-session state file
STATE_DIR="$CLAUDE_PROJECT_DIR/.claude/plan-review"
mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/${SESSION_ID}.json"

state_init() {
  jq -n "$@" > "$STATE_FILE"
}

state_update() {
  jq -c "$@" "$STATE_FILE" > "${STATE_FILE}.tmp" \
    && mv "${STATE_FILE}.tmp" "$STATE_FILE" 2>/dev/null
}

if [ -f "$STATE_FILE" ]; then
  PLAN_REVIEW_JSON=$(cat "$STATE_FILE")
else
  PLAN_REVIEW_JSON="{}"
fi

update_plan_review_file() {
  local INPUT_FILE_PATH
  INPUT_FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
  if [ -z "$INPUT_FILE_PATH" ]; then
    return 0
  fi

  local stored_file_path
  stored_file_path=$(echo "$PLAN_REVIEW_JSON" | jq -r '.file_path // empty' 2>/dev/null)

  if [ "$INPUT_FILE_PATH" != "$stored_file_path" ]; then
    # New plan file — full reset
    state_init \
      --arg fp "$INPUT_FILE_PATH" \
      --argjson ts "$(date +%s)" \
      '{file_path: $fp, reviews: 0, timestamp: $ts}'
  else
    # Same plan file — single atomic write, codex_thread_id conditionally included
    local reviews codex_tid
    reviews=$(echo "$PLAN_REVIEW_JSON" | jq -r '.reviews // 0')
    codex_tid=$(echo "$PLAN_REVIEW_JSON" | jq -r '.codex_thread_id // empty' 2>/dev/null)
    state_init \
      --arg fp "$INPUT_FILE_PATH" \
      --argjson rev "$reviews" \
      --argjson ts "$(date +%s)" \
      --arg tid "${codex_tid:-}" \
      '{file_path: $fp, reviews: $rev, timestamp: $ts}
       + (if $tid != "" then {codex_thread_id: $tid} else {} end)'
  fi
  log "- update state: $STATE_FILE"
}

parse_codex_jsonl() {
  local jsonl_output="$1"
  CODEX_THREAD_ID=""
  CODEX_REVIEW_TEXT=""
  CODEX_THREAD_ID=$(printf '%s\n' "$jsonl_output" \
    | jq -R -r 'fromjson? | select(.type == "thread.started") | .thread_id // empty' 2>/dev/null \
    | head -1)
  CODEX_REVIEW_TEXT=$(printf '%s\n' "$jsonl_output" \
    | jq -R -r 'fromjson? | select(.type == "item.completed" and .item.type == "agent_message") | .item.text // empty' 2>/dev/null \
    | paste -sd $'\n' -)
}

codex_exec_fresh() {
  codex exec --json -m gpt-5.4 -s read-only "$1"
}

plan_review() {
  local file_path
  file_path=$(echo "$PLAN_REVIEW_JSON" | jq -r '.file_path // empty')
  if [ -z "$file_path" ]; then
    return 0
  fi

  # Check review iteration cap
  local reviews
  reviews=$(jq -r '.reviews // 0' "$STATE_FILE")
  if [ "$reviews" -ge 3 ]; then
    return 0
  fi

  # Increment reviews BEFORE codex call (counts attempts, not successes)
  state_update '.reviews = (.reviews // 0) + 1'

  log "- review plan: $file_path (attempt $((reviews + 1)))"

  # Build prompt once, reuse for both exec and resume
  local prompt
  prompt="/review Review the implementation plan in @${file_path}. You have to focus on:
1. Correctness - Will this plan achieve the stated goals?
2. Risks - What could go wrong? Edge cases? Data loss?
3. Missing steps - Is anything forgotten?
4. Alternatives - Is there a simpler or better approach?
5. Security - Any security concerns?

Be specific and actionable. If the plan is solid and ready to implement, end your review with exactly: VERDICT: APPROVED

If changes are needed, end with exactly: VERDICT: REVISE"

  # Determine whether to exec or resume
  local codex_thread_id
  codex_thread_id=$(echo "$PLAN_REVIEW_JSON" | jq -r '.codex_thread_id // empty')

  local codex_output codex_rc
  if [ -n "$codex_thread_id" ]; then
    log "- resuming codex thread: ${codex_thread_id:0:8}..."
    codex_output=$(codex exec resume --json "$codex_thread_id" "$prompt") && codex_rc=0 || codex_rc=$?
    parse_codex_jsonl "$codex_output"

    # Retry with fresh exec if resume failed (non-zero exit OR empty text)
    if [ "$codex_rc" -ne 0 ] || [ -z "$CODEX_REVIEW_TEXT" ]; then
      log "- resume failed (rc=$codex_rc), retrying with fresh exec"
      codex_output=$(codex_exec_fresh "$prompt") && codex_rc=0 || codex_rc=$?
      parse_codex_jsonl "$codex_output"
    fi
  else
    codex_output=$(codex_exec_fresh "$prompt") && codex_rc=0 || codex_rc=$?
    parse_codex_jsonl "$codex_output"
  fi

  # Persist thread_id ONLY on successful run (rc=0 AND non-empty text)
  if [ "$codex_rc" -eq 0 ] && [ -n "$CODEX_REVIEW_TEXT" ] && [ -n "$CODEX_THREAD_ID" ]; then
    state_update --arg tid "$CODEX_THREAD_ID" '.codex_thread_id = $tid' || true
    log "- saved codex thread: ${CODEX_THREAD_ID:0:8}..."
  fi

  local review_results="$CODEX_REVIEW_TEXT"
  log "- review results: $review_results"

  if [[ "$review_results" == *"VERDICT: APPROVED"* ]]; then
    # Clear thread_id — review cycle complete, avoid stale context
    state_update 'del(.codex_thread_id)' || true
    return 0
  fi

  # Emit deny response — use backtick path (no Markdown link injection risk)
  local reason
  reason=$(printf '%s was blocked by plan-review hook.\nRevise the original plan `%s` based on the following review results.\nThen, ask me to approve your update plan by ExitPlanMode after you complete improving your plan.\n\n## Review Results\n%s' \
    "$TOOL_NAME" "$file_path" "$review_results")

  jq -n \
    --arg event "$HOOK_EVENT_NAME" \
    --arg reason "$reason" \
    '{hookSpecificOutput: {hookEventName: $event, permissionDecision: "deny", permissionDecisionReason: $reason}}'
}

# Main dispatch — errors in state management should not block the user
if [ "$TOOL_NAME" = "ExitPlanMode" ]; then
  plan_review || { log "- plan_review failed, allowing exit"; }
else
  update_plan_review_file || { log "- update failed, continuing"; }
fi

exit 0

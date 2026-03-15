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
echo "=== $(date '+%Y-%m-%d %H:%M:%S') $HOOK_EVENT_NAME ($TOOL_NAME) hook executed ===" >> "$LOG_FILE"

# Per-session state file
STATE_DIR="$CLAUDE_PROJECT_DIR/.claude/plan-review"
mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/${SESSION_ID}.json"

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
  local reviews
  reviews=$(echo "$PLAN_REVIEW_JSON" | jq -r '.reviews // 0')
  jq -n \
    --arg fp "$INPUT_FILE_PATH" \
    --argjson rev "$reviews" \
    --argjson ts "$(date +%s)" \
    '{file_path: $fp, reviews: $rev, timestamp: $ts}' > "$STATE_FILE"
  echo "- update state: $STATE_FILE" >> "$LOG_FILE"
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

  # Increment reviews BEFORE codex exec (counts attempts, not successes)
  jq -c '.reviews = (.reviews // 0) + 1' "$STATE_FILE" > "${STATE_FILE}.tmp" \
    && mv "${STATE_FILE}.tmp" "$STATE_FILE"

  echo "- review plan: $file_path (attempt $((reviews + 1)))" >> "$LOG_FILE"

  # codex failure or non-APPROVED output is treated as deny (fail-safe)
  local review_results
  review_results=$(codex exec \
    -m gpt-5.4 \
    -s read-only \
    "/review Review the implementation plan in @${file_path}. You have to focus on:
1. Correctness - Will this plan achieve the stated goals?
2. Risks - What could go wrong? Edge cases? Data loss?
3. Missing steps - Is anything forgotten?
4. Alternatives - Is there a simpler or better approach?
5. Security - Any security concerns?

Be specific and actionable. If the plan is solid and ready to implement, end your review with exactly: VERDICT: APPROVED

If changes are needed, end with exactly: VERDICT: REVISE") || true

  echo "- review results: $review_results" >> "$LOG_FILE"

  if [[ "$review_results" == *"VERDICT: APPROVED"* ]]; then
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
  plan_review || { echo "- plan_review failed, allowing exit" >> "$LOG_FILE"; }
else
  update_plan_review_file || { echo "- update failed, continuing" >> "$LOG_FILE"; }
fi

exit 0

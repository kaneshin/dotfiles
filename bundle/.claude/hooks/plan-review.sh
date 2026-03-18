#!/bin/bash

# Plan review hook — runs an external review (codex CLI) when ExitPlanMode is invoked.
# State is stored per-session in .claude/plan-review/<session_id>.json.

# This hook only operates within a project directory.
if [ -z "$CLAUDE_PROJECT_DIR" ]; then
  exit 0
fi

cd "$CLAUDE_PROJECT_DIR"

# Config defaults
MAX_REVIEWS=3
MIN_REVIEWS=1
CODEX_MODEL="gpt-5.4"

_read_plan_review_config() {
  local f="$1"
  [ -f "$f" ] || return 0
  local val
  val=$(jq -r '.planReview.maxReviews | select(type=="number" and . >= 1 and floor == .)' "$f" 2>/dev/null)
  [ -n "$val" ] && MAX_REVIEWS=$val
  val=$(jq -r '.planReview.minReviews | select(type=="number" and . >= 1 and floor == .)' "$f" 2>/dev/null)
  [ -n "$val" ] && MIN_REVIEWS=$val
  val=$(jq -r '.planReview.codex.model | select(type=="string" and length > 0)' "$f" 2>/dev/null)
  [ -n "$val" ] && CODEX_MODEL=$val
}

_read_plan_review_config "$HOME/.claude/settings.json"
_read_plan_review_config "$CLAUDE_PROJECT_DIR/.claude/settings.json"
_read_plan_review_config "$CLAUDE_PROJECT_DIR/.claude/settings.local.json"

# Enforce invariant: maxReviews must be >= minReviews
[ "$MAX_REVIEWS" -lt "$MIN_REVIEWS" ] && MAX_REVIEWS=$MIN_REVIEWS

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
echo "- settings: max=$MAX_REVIEWS min=$MIN_REVIEWS model=$CODEX_MODEL" >> "$LOG_FILE"

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

  local stored_file_path
  stored_file_path=$(echo "$PLAN_REVIEW_JSON" | jq -r '.file_path // empty' 2>/dev/null)

  if [ "$INPUT_FILE_PATH" != "$stored_file_path" ]; then
    # New plan file — full reset
    jq -n \
      --arg fp "$INPUT_FILE_PATH" \
      --argjson ts "$(date +%s)" \
      '{file_path: $fp, reviews: 0, timestamp: $ts}' > "$STATE_FILE"
  else
    # Same plan file — preserve all fields
    local reviews codex_tid codex_mdl
    reviews=$(echo "$PLAN_REVIEW_JSON" | jq -r '.reviews // 0')
    codex_tid=$(echo "$PLAN_REVIEW_JSON" | jq -r '.codex_thread_id // empty' 2>/dev/null)
    codex_mdl=$(echo "$PLAN_REVIEW_JSON" | jq -r '.codex_model // empty' 2>/dev/null)
    if [ -n "$codex_tid" ]; then
      if [ -n "$codex_mdl" ]; then
        jq -n --arg fp "$INPUT_FILE_PATH" --argjson rev "$reviews" --argjson ts "$(date +%s)" \
          --arg tid "$codex_tid" --arg model "$codex_mdl" \
          '{file_path: $fp, reviews: $rev, timestamp: $ts, codex_thread_id: $tid, codex_model: $model}' > "$STATE_FILE"
      else
        jq -n --arg fp "$INPUT_FILE_PATH" --argjson rev "$reviews" --argjson ts "$(date +%s)" \
          --arg tid "$codex_tid" \
          '{file_path: $fp, reviews: $rev, timestamp: $ts, codex_thread_id: $tid}' > "$STATE_FILE"
      fi
    else
      jq -n --arg fp "$INPUT_FILE_PATH" --argjson rev "$reviews" --argjson ts "$(date +%s)" \
        '{file_path: $fp, reviews: $rev, timestamp: $ts}' > "$STATE_FILE"
    fi
  fi
  echo "- update state: $STATE_FILE" >> "$LOG_FILE"
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

plan_review() {
  local file_path
  file_path=$(echo "$PLAN_REVIEW_JSON" | jq -r '.file_path // empty')
  if [ -z "$file_path" ]; then
    return 0
  fi

  # Check review iteration cap
  local reviews
  reviews=$(jq -r '.reviews // 0' "$STATE_FILE")
  if [ "$reviews" -ge "$MAX_REVIEWS" ]; then
    return 0
  fi

  # Increment reviews BEFORE codex call (counts attempts, not successes)
  jq -c '.reviews = (.reviews // 0) + 1' "$STATE_FILE" > "${STATE_FILE}.tmp" \
    && mv "${STATE_FILE}.tmp" "$STATE_FILE"

  echo "- review plan: $file_path (attempt $((reviews + 1)))" >> "$LOG_FILE"

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

  # Invalidate thread if model has changed or is missing (legacy state)
  local stored_model
  stored_model=$(echo "$PLAN_REVIEW_JSON" | jq -r '.codex_model // empty')
  if [ -n "$codex_thread_id" ]; then
    if [ -z "$stored_model" ]; then
      echo "- stored codex_model missing for thread ${codex_thread_id:0:8}..., clearing stale thread" >> "$LOG_FILE"
      codex_thread_id=""
    elif [ "$stored_model" != "$CODEX_MODEL" ]; then
      echo "- model changed ($stored_model -> $CODEX_MODEL), clearing thread" >> "$LOG_FILE"
      codex_thread_id=""
    fi
  fi

  local codex_output codex_rc
  if [ -n "$codex_thread_id" ]; then
    echo "- resuming codex thread: ${codex_thread_id:0:8}..." >> "$LOG_FILE"
    codex_output=$(codex exec resume --json "$codex_thread_id" "$prompt") && codex_rc=0 || codex_rc=$?
    parse_codex_jsonl "$codex_output"

    # Retry with fresh exec if resume failed (non-zero exit OR empty text)
    if [ "$codex_rc" -ne 0 ] || [ -z "$CODEX_REVIEW_TEXT" ]; then
      echo "- resume failed (rc=$codex_rc), retrying with fresh exec" >> "$LOG_FILE"
      codex_output=$(codex exec --json -m "$CODEX_MODEL" -s read-only "$prompt") && codex_rc=0 || codex_rc=$?
      parse_codex_jsonl "$codex_output"
    fi
  else
    codex_output=$(codex exec --json -m "$CODEX_MODEL" -s read-only "$prompt") && codex_rc=0 || codex_rc=$?
    parse_codex_jsonl "$codex_output"
  fi

  # Persist thread_id ONLY on successful run (rc=0 AND non-empty text)
  if [ "$codex_rc" -eq 0 ] && [ -n "$CODEX_REVIEW_TEXT" ] && [ -n "$CODEX_THREAD_ID" ]; then
    jq -c --arg tid "$CODEX_THREAD_ID" --arg model "$CODEX_MODEL" \
      '.codex_thread_id = $tid | .codex_model = $model' \
      "$STATE_FILE" > "${STATE_FILE}.tmp" \
      && mv "${STATE_FILE}.tmp" "$STATE_FILE" 2>/dev/null || true
    echo "- saved codex thread: ${CODEX_THREAD_ID:0:8}..." >> "$LOG_FILE"
  fi

  local review_results="$CODEX_REVIEW_TEXT"
  echo "- review results: $review_results" >> "$LOG_FILE"

  if [[ "$review_results" == *"VERDICT: APPROVED"* ]]; then
    # Always clear thread on APPROVED — any subsequent required pass starts fresh
    jq -c 'del(.codex_thread_id) | del(.codex_model)' "$STATE_FILE" > "${STATE_FILE}.tmp" \
      && mv "${STATE_FILE}.tmp" "$STATE_FILE" 2>/dev/null || true

    local current_reviews
    current_reviews=$(jq -r '.reviews // 0' "$STATE_FILE")
    if [ "$current_reviews" -ge "$MIN_REVIEWS" ]; then
      return 0  # allow
    fi
    review_results=$(printf '%s\n\nMinimum review count not reached (%s/%s). Trigger ExitPlanMode again.' \
      "$review_results" "$current_reviews" "$MIN_REVIEWS")
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

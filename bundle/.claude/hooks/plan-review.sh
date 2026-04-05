#!/bin/bash

# Plan review hook — runs an external review (Codex CLI or Claude Code) when ExitPlanMode is invoked.
# State is stored per-session in .claude/plan-review/<session_id>.json.
# Pass --debug to enable log output to ~/.claude/logs/plan-review.log.

# Parse flags
DEBUG=false
for _arg in "$@"; do
  case "$_arg" in --debug) DEBUG=true ;; esac
done
#
#    "PreToolUse": [
#      {
#        "matcher": "ExitPlanMode",
#        "hooks": [
#          {
#            "type": "command",
#            "command": "~/.claude/hooks/plan-review.sh"
#          }
#        ]
#      }
#    ],
#    "PostToolUse": [
#      {
#        "matcher": "Edit|Write",
#        "hooks": [
#          {
#            "type": "command",
#            "command": "~/.claude/hooks/plan-review.sh"
#          }
#        ]
#      }
#    ],

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

# Config defaults (only needed for plan permission mode)
PLAN_REVIEW_ENABLED="true"
MAX_REVIEWS=3
REVIEW_MODEL="sonnet"
REVIEW_PROMPT="You are reviewing a proposed implementation plan for this coding session.\n\nEvaluate the plan using these criteria:\n\n1. Correctness & feasibility\n   - Does the plan correctly address the user’s request and constraints?\n   - Are the steps technically sound and realistic to implement?\n2. Safety & risk\n   - Does the plan avoid data loss, security issues, or breaking changes?\n   - Are risky operations (e.g., destructive edits, migrations) highlighted and mitigated?\n3. Clarity & structure\n   - Is the plan broken into clear, ordered steps?\n   - Would another engineer be able to follow these steps without confusion?\n4. Completeness & scope\n   - Does the plan cover all major parts of the task (code, tests, docs, config, deployment, etc.)?\n   - Is the scope appropriate (not missing key work, not including unnecessary work)?\n5. Dependencies & validation\n   - Does the plan identify important dependencies, assumptions, or prerequisites?\n   - Does it include validation or testing steps to confirm the changes work?\n\nIn your review, briefly summarize strengths and weaknesses of the plan, then conclude with a clear recommendation such as:\n- APPROVE: The plan is solid as-is.\n- APPROVE WITH NITS: The plan is fine but could be slightly improved.\n- REVISE: The plan has issues that should be fixed before proceeding.\n- REJECT: The plan is unsafe, incorrect, or not aligned with the request."

_read_plan_review_config() {
  local f="$1"
  [ -f "$f" ] || return 0
  local val
  val=$(jq -r '.planReview.enabled | select(type=="boolean")' "$f" 2>/dev/null)
  [ -n "$val" ] && PLAN_REVIEW_ENABLED=$val
  val=$(jq -r '.planReview.maxReviews | select(type=="number" and . >= 1 and floor == .)' "$f" 2>/dev/null)
  [ -n "$val" ] && MAX_REVIEWS=$val
  val=$(jq -r '(.planReview.model // .planReview.codex.model) | select(type=="string" and length > 0)' "$f" 2>/dev/null)
  [ -n "$val" ] && REVIEW_MODEL=$val
  val=$(jq -r '.planReview.prompt | select(type=="string" and length > 0)' "$f" 2>/dev/null)
  [ -n "$val" ] && REVIEW_PROMPT=$val
}

_read_plan_review_config "$HOME/.claude/settings.json"
_read_plan_review_config "$CLAUDE_PROJECT_DIR/.claude/settings.json"
_read_plan_review_config "$CLAUDE_PROJECT_DIR/.claude/settings.local.json"

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
HOOK_EVENT_NAME=$(echo "$INPUT" | jq -r '.hook_event_name // empty')
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Logging — only writes when --debug is passed
LOG_FILE="$HOME/.claude/logs/plan-review.log"
log() {
  [ "$DEBUG" = "true" ] || return 0
  mkdir -p "$(dirname "$LOG_FILE")"
  echo "$1" >> "$LOG_FILE"
}
log "=== $(date '+%Y-%m-%d %H:%M:%S') $HOOK_EVENT_NAME ($TOOL_NAME) hook executed ==="
log "- settings: enabled=$PLAN_REVIEW_ENABLED max=$MAX_REVIEWS model=$REVIEW_MODEL prompt=$(echo "$REVIEW_PROMPT" | head -1)..."

if [ "$PLAN_REVIEW_ENABLED" = "false" ]; then
  log "- plan review disabled, exiting"
  exit 0
fi

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
    # Same plan file — single atomic write, optional fields merged via jq
    local reviews tid mdl
    reviews=$(echo "$PLAN_REVIEW_JSON" | jq -r '.reviews // 0')
    tid=$(echo "$PLAN_REVIEW_JSON" | jq -r '.thread_id // empty' 2>/dev/null)
    mdl=$(echo "$PLAN_REVIEW_JSON" | jq -r '.model // empty' 2>/dev/null)
    state_init \
      --arg fp "$INPUT_FILE_PATH" \
      --argjson rev "$reviews" \
      --argjson ts "$(date +%s)" \
      --arg tid "${tid:-}" \
      --arg model "${mdl:-}" \
      '{file_path: $fp, reviews: $rev, timestamp: $ts}
       + (if $tid != "" then {thread_id: $tid} else {} end)
       + (if $model != "" then {model: $model} else {} end)'
  fi
  log "- update state: $STATE_FILE"
}

parse_codex_jsonl() {
  local jsonl_output="$1"
  REVIEW_THREAD_ID=""
  REVIEW_TEXT=""
  REVIEW_THREAD_ID=$(printf '%s\n' "$jsonl_output" \
    | jq -R -r 'fromjson? | select(.type == "thread.started") | .thread_id // empty' 2>/dev/null \
    | head -1)
  REVIEW_TEXT=$(printf '%s\n' "$jsonl_output" \
    | jq -R -r 'fromjson? | select(.type == "item.completed" and .item.type == "agent_message") | .item.text // empty' 2>/dev/null \
    | paste -sd $'\n' -)
}

is_codex_model() {
  case "$1" in gpt-*) return 0 ;; *) return 1 ;; esac
}

codex_exec_fresh() {
  codex exec --json -m "$REVIEW_MODEL" -s read-only "$1"
}

claude_exec_fresh() {
  env -u CLAUDECODE claude -p "$1" \
    --output-format json --model "$REVIEW_MODEL" --allowedTools "Read"
}

parse_claude_json() {
  local json_output="$1"
  REVIEW_THREAD_ID=""
  REVIEW_TEXT=""
  REVIEW_THREAD_ID=$(printf '%s' "$json_output" \
    | jq -r '.session_id // empty' 2>/dev/null)
  REVIEW_TEXT=$(printf '%s' "$json_output" \
    | jq -r '.result // empty' 2>/dev/null)
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
  state_update '.reviews = (.reviews // 0) + 1'

  log "- review plan: $file_path (attempt $((reviews + 1)))"

  # Build prompt once, reuse for both exec and resume
  local prompt
  prompt="Review the implementation plan in @${file_path}.
${REVIEW_PROMPT}

Be specific and actionable.
If the plan is solid and ready to implement, end your review with exactly: VERDICT: APPROVED
If changes are needed, end with exactly: VERDICT: REVISE"

  # Determine whether to exec or resume
  local thread_id
  thread_id=$(echo "$PLAN_REVIEW_JSON" | jq -r '.thread_id // empty')

  # Invalidate thread if model has changed or is missing (legacy state)
  local stored_model
  stored_model=$(echo "$PLAN_REVIEW_JSON" | jq -r '.model // empty')
  if [ -n "$thread_id" ]; then
    if [ -z "$stored_model" ]; then
      log "- stored model missing for thread ${thread_id:0:8}..., clearing stale thread"
      thread_id=""
    elif [ "$stored_model" != "$REVIEW_MODEL" ]; then
      log "- model changed ($stored_model -> $REVIEW_MODEL), clearing thread"
      thread_id=""
    fi
  fi

  local review_output review_rc
  if is_codex_model "$REVIEW_MODEL"; then
    # Codex CLI path
    if [ -n "$thread_id" ]; then
      log "- resuming codex thread: ${thread_id:0:8}..."
      review_output=$(codex exec resume --json "$thread_id" "$prompt") && review_rc=0 || review_rc=$?
      parse_codex_jsonl "$review_output"

      if [ "$review_rc" -ne 0 ] || [ -z "$REVIEW_TEXT" ]; then
        log "- resume failed (rc=$review_rc), retrying with fresh exec"
        review_output=$(codex_exec_fresh "$prompt") && review_rc=0 || review_rc=$?
        parse_codex_jsonl "$review_output"
      fi
    else
      review_output=$(codex_exec_fresh "$prompt") && review_rc=0 || review_rc=$?
      parse_codex_jsonl "$review_output"
    fi
  else
    # Claude Code headless path
    if [ -n "$thread_id" ]; then
      log "- resuming claude session: ${thread_id:0:8}..."
      review_output=$(env -u CLAUDECODE claude -p "$prompt" \
        --output-format json --resume "$thread_id") && review_rc=0 || review_rc=$?
      parse_claude_json "$review_output"

      if [ "$review_rc" -ne 0 ] || [ -z "$REVIEW_TEXT" ]; then
        log "- resume failed (rc=$review_rc), retrying with fresh exec"
        review_output=$(claude_exec_fresh "$prompt") && review_rc=0 || review_rc=$?
        parse_claude_json "$review_output"
      fi
    else
      review_output=$(claude_exec_fresh "$prompt") && review_rc=0 || review_rc=$?
      parse_claude_json "$review_output"
    fi
  fi

  # Persist thread_id ONLY on successful run (rc=0 AND non-empty text)
  if [ "$review_rc" -eq 0 ] && [ -n "$REVIEW_TEXT" ] && [ -n "$REVIEW_THREAD_ID" ]; then
    state_update --arg tid "$REVIEW_THREAD_ID" --arg model "$REVIEW_MODEL" \
      '.thread_id = $tid | .model = $model' || true
    log "- saved thread: ${REVIEW_THREAD_ID:0:8}..."
  fi

  local review_results="$REVIEW_TEXT"
  log "- review results: $review_results"

  local last_line trimmed_last_line
  # Extract the final non-empty line from the review results
  last_line=$(printf '%s\n' "$review_results" | awk 'NF{last=$0} END{if (length(last)) print last}')
  # Trim leading/trailing whitespace from the final non-empty line
  trimmed_last_line=$(printf '%s' "$last_line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  if [[ "$trimmed_last_line" == "VERDICT: APPROVED" ]]; then
    state_update 'del(.thread_id) | del(.model)' || true
    return 0  # allow
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

#!/bin/bash

# This script is allowed to run in a project directory.
if [ -z "$CLAUDE_PROJECT_DIR" ]; then
  exit 0
fi

# change working directory
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
[ ! -d "$LOG_DIR" ] && mkdir -p $LOG_DIR
LOG_FILE="$LOG_DIR/plan-review.log"
echo "=== $(date '+%Y-%m-%d %H:%M:%S') $HOOK_EVENT_NAME ($TOOL_NAME) hook executed ===" >> "$LOG_FILE"

# plan-review file to store something
PLAN_REVIEW_FILE="$CLAUDE_PROJECT_DIR/.claude/plan-review.jsonl"
[ ! -f "$PLAN_REVIEW_FILE" ] && touch "$PLAN_REVIEW_FILE"
PLAN_REVIEW_JSON=$(jq -c "if .session_id == \"$SESSION_ID\" then . else empty end" "$PLAN_REVIEW_FILE")
[ -z "$PLAN_REVIEW_JSON" ] && PLAN_REVIEW_JSON="{}"

update_plan_review_file() {
  local INPUT_FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
  if [ -z "$INPUT_FILE_PATH" ]; then
    exit 0
  fi
  local data=$(jq -nc "{
      session_id: \"$SESSION_ID\",
      file_path: \"$INPUT_FILE_PATH\",
      reviews: $(echo "$PLAN_REVIEW_JSON" | jq -r '.reviews // 0'),
      timestamp: $(date +%s)
    }")
  echo "- update plan-review.jsonl: $data" >> "$LOG_FILE"

  if [ "$PLAN_REVIEW_JSON" = "{}" ]; then
    echo "$data" >> "$PLAN_REVIEW_FILE"
  else
    local tmp_file="$CLAUDE_PROJECT_DIR/.claude/plan-review.tmp.jsonl"
    jq -c "if .session_id == \"$SESSION_ID\" then . = $data end" "$PLAN_REVIEW_FILE" > "$tmp_file"
    mv "$tmp_file" "$PLAN_REVIEW_FILE"
  fi
}

plan_review() {
  local file_path=$(echo "$PLAN_REVIEW_JSON" | jq -r '.file_path // empty')
  if [ -z "$file_path" ]; then
    exit 0
  fi
  # check and save review iteration
  local reviews=$(jq -c "if .session_id == \"$SESSION_ID\" then . else empty end | .reviews" "$PLAN_REVIEW_FILE")
  if [ "$reviews" = "3" ]; then
    exit 0
  fi
  local tmp_file="$CLAUDE_PROJECT_DIR/.claude/plan-review.tmp.jsonl"
  jq -c "if .session_id == \"$SESSION_ID\" then .reviews = .reviews+1 end" "$PLAN_REVIEW_FILE" > "$tmp_file"
  mv "$tmp_file" "$PLAN_REVIEW_FILE"
  echo "- review plan: $file_path" >> "$LOG_FILE"
  local review_results=$(codex exec \
    -m gpt-5.4 \
    -s read-only \
    "/review Review the implementation plan in @${file_path}. You have to focus on:
1. Correctness - Will this plan achieve the stated goals?
2. Risks - What could go wrong? Edge cases? Data loss?
3. Missing steps - Is anything forgotten?
4. Alternatives - Is there a simpler or better approach?
5. Security - Any security concerns?

Be specific and actionable. If the plan is solid and ready to implement, end your review with exactly: VERDICT: APPROVED

If changes are needed, end with exactly: VERDICT: REVISE")
  echo "- review plan results: $review_results" >> "$LOG_FILE"
  if [[ "$review_results" == *"VERDICT: APPROVED"* ]]; then
    exit 0
  fi
  local data="{
    hookSpecificOutput: {
      hookEventName: \"$HOOK_EVENT_NAME\",
      permissionDecision: \"deny\",
      permissionDecisionReason: \"$TOOL_NAME was blocked by plan-review hook.
Revise [this original plan]($file_path) based on the following review results.
Then, ask me to approve your update plan by ExitPlanMode after you complete improving your plan.

## Review Results
${review_results//\"/\\\"}\"
    }
  }"
  echo "- review plan output: $data" >> "$LOG_FILE"
  jq -n "$data" 2>&1 >> "$LOG_FILE"
  jq -n "$data"
}

if [ "$TOOL_NAME" = "ExitPlanMode" ]; then
  plan_review
else
  update_plan_review_file
fi

exit 0



# claude settings files in order
SETTINGS="$HOME/.claude/settings.json"
if [ -n "$CLAUDE_PROJECT_DIR" ]; then
  prj_settings="$CLAUDE_PROJECT_DIR/.claude/settings.json"
  if [ -f "$prj_settings" ]; then
    SETTINGS="$SETTINGS\n$prj_settings"
  fi
  prj_local_settings="$CLAUDE_PROJECT_DIR/.claude/settings.local.json"
  if [ -f "$prj_local_settings" ]; then
    SETTINGS="$SETTINGS\n$prj_local_settings"
  fi
fi
SETTINGS=$(echo -e "$SETTINGS")

PLANS_DIR="$HOME/.claude/plans/" # default
while IFS= read -r settings; do
  [ ! -f "$settings" ] && continue

  dir=$(jq -r '.plansDirectory // empty' "$settings")
  if [ -n "$dir" ]; then
    PLANS_DIR="$dir"
  fi
done <<<"$SETTINGS"


# 1. get the latest plan file
#   ls -t .claude/plans/ | head -1
#   Or to get the full path:
#   ls -t .claude/plans/ | head -1 | xargs -I{} echo .claude/plans/{}
# 2. review the plan file

exit 0



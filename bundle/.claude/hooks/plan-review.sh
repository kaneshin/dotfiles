#!/bin/bash

# This script is allowed to run in a project directory.
if [ -z "$CLAUDE_PROJECT_DIR" ]; then
  exit 0
fi

# change working directory
cd "$CLAUDE_PROJECT_DIR"

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
PERMISSION_MODE=$(echo "$INPUT" | jq -r '.permission_mode // empty')
HOOK_EVENT_NAME=$(echo "$INPUT" | jq -r '.hook_event_name // empty')
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

if [ "$PERMISSION_MODE" != "plan" ]; then
  exit 0
fi

# Logging
LOG_DIR="$HOME/.claude/logs"
[ ! -d "$LOG_DIR" ] && mkdir -p $LOG_DIR
LOG_FILE="$LOG_DIR/plan-review.log"
echo "=== $(date '+%Y-%m-%d %H:%M:%S') $HOOK_EVENT_NAME ($TOOL_NAME) hook executed ===" >> "$LOG_FILE"

# plan-review file to store something
PLAN_REVIEW_FILE="$CLAUDE_PROJECT_DIR/.claude/plan-review.jsonl"
[ ! -f "$PLAN_REVIEW_FILE" ] && touch "$PLAN_REVIEW_FILE"

update_plan_review_file() {
  local INPUT_FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
  if [ -z "$INPUT_FILE_PATH" ]; then
    exit 0
  fi
  local data=$(jq -nc "{
      session_id: \"$SESSION_ID\",
      file_path: \"$INPUT_FILE_PATH\"
    }")
  echo "- update plan-review.jsonl: $data" >> "$LOG_FILE"

  local json=$(jq "if .session_id == \"$SESSION_ID\" then . else empty end" "$PLAN_REVIEW_FILE")
  if [ -n "$json" ]; then
    local tmp_file="$CLAUDE_PROJECT_DIR/.claude/plan-review.tmp.jsonl"
    jq -c "if .session_id == \"$SESSION_ID\" then .file_path = \"$INPUT_FILE_PATH\" end" "$PLAN_REVIEW_FILE" > "$tmp_file"
    mv "$tmp_file" "$PLAN_REVIEW_FILE"
  else
    echo "$data" >> "$PLAN_REVIEW_FILE"
  fi
}

plan_review() {
  local data=$(jq "if .session_id == \"$SESSION_ID\" then . else empty end" "$PLAN_REVIEW_FILE")
  if [ -z "$data" ]; then
    exit 0
  fi
  local file_path=$(echo "$data" | jq -r '.file_path // empty')
  if [ -z "$file_path" ]; then
    exit 0
  fi
  echo "- review plan: $file_path" >> "$LOG_FILE"
  local result=$(codex exec resume --last -m gpt-5.4 "/review @${file_path}")
  echo "- review plan result: $result" >> "$LOG_FILE"
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



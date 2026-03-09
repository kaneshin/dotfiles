#!/bin/bash

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
while [[ "$COMMAND" == *"  "* ]]; do
  COMMAND="${COMMAND//  / }"
done
COMMANDS="$COMMAND"
NL=$'\n'
COMMANDS="${COMMANDS//;/$NL}"
COMMANDS="${COMMANDS//&&/$NL}"
COMMANDS="${COMMANDS//\|\|/$NL}"
COMMANDS="${COMMANDS//\|/$NL}"

extract_patterns() {
  local list=$(cat)
  echo "$list" | jq -r '.[] | select(startswith("Bash(")) | gsub("^Bash\\("; "") | gsub("\\)$"; "")'
}
settings=$(cat "$HOME/.claude/settings.json")

# Deny
deny_patterns=$(echo "$settings" | jq -r '.permissions.deny // []' | extract_patterns)

is_command_denied() {
  local cmd="$1"
  cmd="${cmd#"${cmd%%[![:space:]]*}"}"
  cmd="${cmd%"${cmd##*[![:space:]]}"}"

  while IFS= read -r pattern; do
    [ -z "$pattern" ] && continue

    local glob="${pattern//:*/*}"
    if [[ "$cmd" == $glob ]]; then
      echo "Command Execution Denied by hooks. Pattern: '$pattern'" >&2
      return 0
    fi
  done <<<"$deny_patterns"
  return 1
}

if is_command_denied "$COMMAND"; then
  exit 2
fi
while IFS= read -r cmd; do
  if is_command_denied "$cmd"; then
    exit 2
  fi
done <<<"$COMMANDS"

# Allow
# allow_patterns=$(echo "$settings" | jq -r '.permissions.allow // []' | extract_patterns)

# Ask
# ask_patterns=$(echo "$settings" | jq -r '.permissions.ask // []' | extract_patterns)

exit 0

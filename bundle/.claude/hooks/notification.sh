#!/bin/bash
# notification.sh - Display macOS notifications from Claude Code hooks
#
# Usage: Pipe JSON with title, sub_title, and message fields
# Example: echo '{"title":"Claude","message":"Task complete"}' | ./notification.sh

INPUT=$(cat)
TITLE="Claude Code: $(echo "$INPUT" | jq -r '.title // .notification_type // ""')"
MESSAGE="$(echo "$INPUT" | jq -r '.message // "Notification"')"
SUB_TITLE="$(echo "$INPUT" | jq -r '.hook_event_name // ""')"
if [ -n "$TMUX" ]; then
  SUB_TITLE="$SUB_TITLE on $(tmux display-message -p -t "$TMUX_PANE" 'tmux.#I.#W')"
fi
SOUND="Blow"

osascript -e "display notification \"${MESSAGE}\" with title \"${TITLE}\" subtitle \"${SUB_TITLE}\" sound name \"${SOUND}\""


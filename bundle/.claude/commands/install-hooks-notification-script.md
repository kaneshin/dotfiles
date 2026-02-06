---
name: install-hooks-notification-script
description: Install a macOS notification script for Claude Code hooks
---

Install a notification helper script that displays macOS notifications. This script can be called from Claude Code hooks to notify you when tasks complete.

## Instructions

Create the file `notification.sh` in `${CLAUDE_PROJECT_DIR}/.claude/hooks/` with executable permissions (`chmod +x`).

## Script Content

**notification.sh**

```shell
#!/bin/bash
# notification.sh - Display macOS notifications from Claude Code hooks
#
# Usage: Pipe JSON with title, sub_title, and message fields
# Example: echo '{"title":"Claude","message":"Task complete"}' | ./notification.sh

INPUT=$(cat)
TITLE=$(echo "$INPUT" | jq -r '.title // "notification.sh"')
SUB_TITLE=$(echo "$INPUT" | jq -r '.sub_title // ""')
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Notification"')

osascript -e "display notification \"${MESSAGE}\" with title \"${TITLE}\" subtitle \"${SUB_TITLE}\""
```

## JSON Input Format

| Field | Description | Default |
|-------|-------------|---------|
| `title` | Notification title | `"notification.sh"` |
| `sub_title` | Subtitle text | `""` (empty) |
| `message` | Main notification body | `"Notification"` |

## Requirements

- macOS (uses `osascript`)
- `jq` command-line JSON processor

#!/bin/bash
#
# jq: brew install jq
# fd: brew install fd
# fzf: brew install fzf

INPUT=$(cat)
query=$(echo "$INPUT" | jq -r '.query // empty')

if [ -n "$CLAUDE_PROJECT_DIR" ]; then
  cd "$CLAUDE_PROJECT_DIR"
fi
fd --hidden --no-ignore | fzf --filter="$query" | head -20

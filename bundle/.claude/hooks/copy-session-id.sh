#!/bin/bash

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

if [ -n "$SESSION_ID" ]; then
  echo "$SESSION_ID" | pbcopy
fi

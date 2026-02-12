#!/bin/bash
# plan-review.sh

INPUT=$(cat)

TRANSCRIPT_PATH="$(echo "$INPUT" | jq -r '.transcript_path // empty')"
PLAN="$(echo "$INPUT" | jq -r '.tool_input.plan // empty')"
if [ -z "$PLAN" ]; then
  exit 0
fi


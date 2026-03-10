#!/bin/bash
input=$(cat)

# Helper functions for common extractions
get_model_name() { echo "$input" | jq -r '.model.display_name'; }
get_current_dir() { echo "$input" | jq -r '.workspace.current_dir'; }
get_project_dir() { echo "$input" | jq -r '.workspace.project_dir'; }
get_version() { echo "$input" | jq -r '.version'; }

# Cost
get_cost() { echo "$input" | jq -r '.cost.total_cost_usd'; }
get_duration() { echo "$input" | jq -r '.cost.total_duration_ms'; }
get_lines_added() { echo "$input" | jq -r '.cost.total_lines_added'; }
get_lines_removed() { echo "$input" | jq -r '.cost.total_lines_removed'; }

# Context Window
get_input_tokens() { echo "$input" | jq -r '.context_window.total_input_tokens'; }
get_output_tokens() { echo "$input" | jq -r '.context_window.total_output_tokens'; }
get_context_window_size() { echo "$input" | jq -r '.context_window.context_window_size'; }

# Current Usage
get_current_usage() { echo "$input" | jq '.context_window.current_usage'; }


MODEL=$(get_model_name)
CONTEXT_SIZE=$(get_context_window_size)
USAGE=$(get_current_usage)
CURRENT_TOKENS="0"
PERCENT_USED="0"
if [ "$USAGE" != "null" ]; then
  # Calculate current context from current_usage fields
  CURRENT_TOKENS=$(echo "$USAGE" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
  PERCENT_USED=$((CURRENT_TOKENS * 100 / CONTEXT_SIZE))
fi
echo "[$MODEL] Context: $PERCENT_USED% ($((CURRENT_TOKENS / 1000))k/$((CONTEXT_SIZE / 1000))k)"

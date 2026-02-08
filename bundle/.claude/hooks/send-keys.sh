#!/bin/bash
# send-keys.sh

if [ -n "$TMUX" ]; then
  PORT=3333
  if [ -n "$(lsof -i ":${PORT}")" ]; then
    curl -X POST http://localhost:${PORT}/commands \
      -H 'Content-Type: application/json' \
      -d "{\"command\":\"tmux send-keys -t '${TMUX_PANE}' C-m\"}"
  fi
fi


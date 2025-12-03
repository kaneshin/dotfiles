# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 03-Dec-2025.

if [ -n "$TMUX" ]; then
  function tmux_rename_window() {
    local git_path=$(git rev-parse --show-toplevel 2> /dev/null)
    if [ -n "$git_path" ]; then
      local repo_name=${git_path##*/}
      tmux rename-window "$repo_name"
    else
      local PWD=$(pwd)
      tmux rename-window ${PWD##*/}
    fi
  }

  add-zsh-hook chpwd tmux_rename_window
  tmux_rename_window
fi

# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set ft=sh:

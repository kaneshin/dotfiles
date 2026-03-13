# Dotfiles

Dotfiles management tool + kaneshin's personal dotfiles.

## Commands

- `dotfiles install bundle` - Install dotfiles (symlinks bundle/ files to $HOME)
- `dotfiles install --dry-run bundle` - Preview installation (symlinks to /tmp/sandbox)
- `dotfiles install --force bundle` - Overwrite existing files
- `./tests/layout_test.sh` - Run tmux layout script tests
- `./tests/permissions_test.sh` - Run permissions hook tests

## Architecture

- `bin/dotfiles` - Entry point (symlink to libexec/dotfiles)
- `libexec/` - Subcommands (dotfiles-install, dotfiles-help, dotfiles-version)
- `bundle/` - Dotfiles to install (shell configs, vim, tmux, emacs, claude, etc.)
  - `bundle/.claude/hooks/permissions.sh` - Bash PreToolUse permission hook
- `tests/` - Bash tests for tmux layout script
  - `tests/permissions_test.sh` - Tests for the permissions hook

## Gotchas

- `DOTFILES_ROOT` env var defaults to `~/.dotfiles` if unset.
- All shell scripts must be Bash 3.2 compatible (macOS `/bin/bash`) — no associative arrays, no `&>>`, no `|&`.
- `bundle/.claude/CLAUDE.md` is symlinked to `~/.claude/CLAUDE.md` — it is a **global** file affecting all projects. Do not add project-specific content there.
- `bundle/.claude/` contains Claude Code settings, hooks, and commands — edits here affect all Claude Code usage after `dotfiles install bundle`.
- Installation creates file-level symlinks for directories (not directory-level symlinks), so individual files inside e.g. `.vim/` are symlinked, not the `.vim/` directory itself.

# Dotfiles
o



Dotfiles management tool + kaneshin's personal dotfiles.

## Commands

- `dotfiles install bundle` - Install dotfiles (symlinks bundle/ files to $HOME)
- `dotfiles install --dry-run bundle` - Preview installation (symlinks to /tmp/sandbox)
- `dotfiles install --force bundle` - Overwrite existing files
- `./tests/layout_test.sh` - Run tmux layout script tests

## Architecture

- `bin/dotfiles` - Entry point (symlink to libexec/dotfiles)
- `libexec/` - Subcommands (dotfiles-install, dotfiles-help, dotfiles-version)
- `bundle/` - Dotfiles to install (shell configs, vim, tmux, emacs, claude, etc.)
- `tests/` - Bash tests for tmux layout script

## Gotchas

- `bundle/.claude/CLAUDE.md` is symlinked to `~/.claude/CLAUDE.md` — it is a **global** file affecting all projects. Do not add project-specific content there.
- Installation creates file-level symlinks for directories (not directory-level symlinks), so individual files inside e.g. `.vim/` are symlinked, not the `.vim/` directory itself.
- `DOTFILES_ROOT` env var defaults to `~/.dotfiles` if unset.

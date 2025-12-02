# dotfiles

## Installation

Check out dotfiles where you want it installed.

```shell
git clone https://github.com/kaneshin/dotfiles.git ~/.dotfiles
```

Define environment variable `DOTFILES_ROOT` to point to the path where dotfiles repository is cloned and add `$DOTFILES_ROOT/bin` to your `$PATH` for access to the dotfiles command-line utility.

```shell
export DOTFILES_ROOT="$HOME/.dotfiles"
export PATH="$DOTFILES_ROOT/bin:$PATH"
```

Put dotfiles as symbolic link into home directory.

```shell
dotfiles install $DOTFILES_ROOT/bundle
```

**NOTE:** You can execute dotfiles script directly.

```shell
export DOTFILES_ROOT="$HOME/.dotfiles"
$DOTFILES_ROOT/bin/dotfiles install $DOTFILES_ROOT/bundle
```

## Claude Code Plugin Installation

This repository includes a Claude Code plugin with MCP servers (Context7, deepwiki, serena) and custom commands.

### Install the plugin

```shell
claude plugin marketplace add kaneshin/dotfiles
claude plugin install kaneshin-claude-code-plugin
```

### Verify installation

After installation, you can verify the plugin is installed by checking your Claude Code settings or running:

```shell
claude mcp list
```

## License

[The MIT License (MIT)](http://kaneshin.mit-license.org/)

## Author

Shintaro Kaneko <kaneshin0120@gmail.com>

# dotfiles

A dotfiles management CLI tool and kaneshin's personal dotfiles.

## Installation

Clone the dotfiles repository to your desired location.

```shell
git clone https://github.com/kaneshin/dotfiles.git ~/.dotfiles
```

Define the environment variable `DOTFILES_ROOT` to point to the path where dotfiles repository is cloned and add `$DOTFILES_ROOT/bin` to your `$PATH` for access to the dotfiles command-line utility.

```shell
export DOTFILES_ROOT="$HOME/.dotfiles"
export PATH="$DOTFILES_ROOT/bin:$PATH"
```

## Usage

The `dotfiles` command provides three subcommands:

```
dotfiles help
dotfiles version
dotfiles install <path>
```

Run `dotfiles help` or `dotfiles help install` for details on available flags.

Directories in the bundle are not symlinked as directories — individual files inside them are symlinked at their relative paths under `$HOME`.

> **Note:** Bundles can contain shell startup files (`.zshrc`, `.bash_profile`), git hooks (`.githooks/`), and tool configurations (`.claude/`, `.config/`) that execute automatically or change global tool behavior. Only install bundles you trust and review their contents first.

## Install Your Own Dotfiles

This repository serves as both kaneshin's dotfiles and a general dotfiles management tool. You can use it to install your own dotfiles.

```shell
dotfiles install /path/to/your-dotfiles-bundle
```

**NOTE:** You can execute the dotfiles script directly.

```shell
export DOTFILES_ROOT="$HOME/.dotfiles"
$DOTFILES_ROOT/bin/dotfiles install /path/to/your-dotfiles-bundle
```

### kaneshin's dotfiles

For your reference, here's how to install kaneshin's dotfiles.

```shell
dotfiles install $DOTFILES_ROOT/bundle
```

## License

[The MIT License (MIT)](http://kaneshin.mit-license.org/)

## Author

Shintaro Kaneko <kaneshin0120@gmail.com>

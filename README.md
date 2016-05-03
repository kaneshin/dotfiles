# dotfiles

## Installation

Check out dotfiles where you want it installed.

```
$ git clone https://github.com/kaneshin/dotfiles.git ~/develop/dotfiles
```

Define environment variable `DOTFILES_ROOT` to point to the path where dotfiles repository is cloned and add `$DOTFILES_ROOT/bin` to your `$PATH` for access to the dotfiles command-line utility.

```
$ echo 'export DOTFILES_ROOT="$HOME/develop/dotfiles"' >> ~/.bash_profile
$ echo 'export PATH="$DOTFILES_ROOT/bin:$PATH"' >> ~/.bash_profile
```

Put dotfiles as symbolic link into home directory.

```
$ dotfiles install $DOTFILES_ROOT/bundle
```

**NOTE:** You can execute dotfiles script directly.

```
$ export DOTFILES_ROOT="$HOME/develop/dotfiles"
$ $DOTFILES_ROOT/bin/dotfiles install $DOTFILES_ROOT/bundle
```

## License

[The MIT License (MIT)](http://kaneshin.mit-license.org/)

## Author

Shintaro Kaneko <kaneshin0120@gmail.com>



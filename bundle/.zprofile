# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 04-May-2016.

# local directory
export LOCALROOT="$HOME/local"
export LOCALSRC="$LOCALROOT/src"
export LOCALBIN="$LOCALROOT/bin"

export PATH="/usr/local/bin:$PATH"
export PATH="$LOCALBIN:$PATH"

# setup dotfiles
if [ -d "$HOME/develop/dotfiles" ]; then
  export DOTFILES_ROOT="$HOME/develop/dotfiles"
  export PATH="$DOTFILES_ROOT/bin:$PATH"
fi

# setup rbenv
if [ -d "$HOME/.rbenv" ]; then
  export RBENV_ROOT="$HOME/.rbenv"
  export PATH="$RBENV_ROOT/bin:$PATH"
  which rbenv > /dev/null && eval "$(rbenv init -)"
fi

# setup pyenv
if [ -d "$HOME/.pyenv" ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  which pyenv > /dev/null && eval "$(pyenv init -)"
fi

# setup goenv
if [ -d "$HOME/.goenv" ]; then
  export GOENV_ROOT="$HOME/.goenv"
  export PATH="$GOENV_ROOT/bin:$PATH"
  which goenv > /dev/null && eval "$(goenv init -)"
fi

# setup nodenv
if [ -d "$HOME/.nodenv" ]; then
  export NODENV_ROOT="$HOME/.nodenv"
  export PATH="$NODENV_ROOT/bin:$PATH"
  which nodenv > /dev/null && eval "$(nodenv init -)"
fi

# setup golang
export PATH=$GOROOT/bin:$PATH
export GOPATH="$LOCALROOT"
export GOBIN="$LOCALBIN"
# export PATH="$GOBIN:$PATH" already set
export GO15VENDOREXPERIMENT=1

# setup go_appengine
# export PATH=$PATH:/usr/local/share/google/go_appengine/

# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set ft=sh:

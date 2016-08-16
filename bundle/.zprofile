# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 16-Aug-2016.

# local directory
export LOCALROOT="$HOME/local"
export LOCALSRC="$LOCALROOT/src"
export LOCALBIN="$LOCALROOT/bin"

if [[ ":${PATH}:" != *:"${LOCALBIN}":* ]]; then
  export PATH="/usr/local/bin:$PATH"
  export PATH="$LOCALBIN:$PATH"
fi

# setup dotfiles
if [ -d "$LOCALSRC/github.com/kaneshin/dotfiles" ]; then
  export DOTFILES_ROOT="$LOCALSRC/github.com/kaneshin/dotfiles"
  if [[ ":${PATH}:" != *:"${DOTFILES_ROOT}/bin":* ]]; then
    export PATH="$DOTFILES_ROOT/bin:$PATH"
  fi
fi

# setup rbenv
if [ -d "$HOME/.rbenv" ]; then
  export RBENV_ROOT="$HOME/.rbenv"
  if [[ ":${PATH}:" != *:"${RBENV_ROOT}/bin":* ]]; then
    export PATH="$RBENV_ROOT/bin:$PATH"
    which rbenv > /dev/null && eval "$(rbenv init -)"
  fi
fi

# setup pyenv
if [ -d "$HOME/.pyenv" ]; then
  export PYTHON_CONFIGURE_OPTS="--enable-shared"
  export PYENV_ROOT="$HOME/.pyenv"
  if [[ ":${PATH}:" != *:"${PYENV_ROOT}/bin":* ]]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
    which pyenv > /dev/null && eval "$(pyenv init -)"
  fi
fi

# setup goenv
if [ -d "$HOME/.goenv" ]; then
  export GOENV_ROOT="$HOME/.goenv"
  if [[ ":${PATH}:" != *:"${GOENV_ROOT}/bin":* ]]; then
    export PATH="$GOENV_ROOT/bin:$PATH"
    which goenv > /dev/null && eval "$(goenv init -)"
  fi
fi

# setup nodenv
if [ -d "$HOME/.nodenv" ]; then
  export NODENV_ROOT="$HOME/.nodenv"
  if [[ ":${PATH}:" != *:"${NODENV_ROOT}/bin":* ]]; then
    export PATH="$NODENV_ROOT/bin:$PATH"
    which nodenv > /dev/null && eval "$(nodenv init -)"
  fi
fi

# setup golang
export GOPATH="$LOCALROOT"
export GOBIN="$LOCALBIN"
# export PATH="$GOBIN:$PATH" already set
export GO15VENDOREXPERIMENT=1

# setup go_appengine
# if [ -d "/usr/local/share/google/go_appengine" ]; then
#   export GOAPPENGINE_ROOT="/usr/local/share/google/go_appengine"
#   export PATH="$PATH:$GOAPPENGINE_ROOT"
# fi

# setup ghq
which ghq > /dev/null && export GHQ_ROOT=$LOCALSRC

# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set ft=sh:

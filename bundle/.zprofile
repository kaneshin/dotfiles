# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 13-Dec-2016.

# FXXK OS X
# system-wide environment settings for zsh(1)
if [ -x /usr/libexec/path_helper ]; then
  PATH=""
  eval `/usr/libexec/path_helper -s`
fi

# local directory
export LOCALROOT="$HOME/local"
export LOCALSRC="$LOCALROOT/src"
export LOCALBIN="$LOCALROOT/bin"

if which brew > /dev/null; then
  # setup for OS X
  GNUBIN_PATH="`brew --prefix coreutils`/libexec/gnubin"
  if [ -d "$GNUBIN_PATH" ]; then
    export PATH="$GNUBIN_PATH:$PATH"
    export MANPATH="`brew --prefix coreutils`/libexec/gnuman:$MANPATH"
  fi
fi

# setup local dir
if [[ ":${PATH}:" != *:"${LOCALBIN}":* ]]; then
  # export PATH="/usr/local/bin:$PATH"
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
if [[ ":${PATH}:" != *:"${GOBIN}":* ]]; then
  export PATH="$GOBIN:$PATH"
fi
export GO15VENDOREXPERIMENT=1

# setup ghq
which ghq > /dev/null && export GHQ_ROOT=$LOCALSRC

# setup gcloud
if which gcloud > /dev/null; then
  local gcloud=$(which gcloud)
  # verify symlink
  if [ -n "$(readlink $gcloud)" ]; then
    gcloud=$(cd $(dirname $gcloud); cd $(dirname "$(readlink $gcloud)"); pwd)/gcloud
  fi
  # verify absolute path
  export CLOUDSDK_ROOT=$(cd $(dirname $gcloud)/..; pwd)
fi

# local
[ -f ~/.profile.local ] && source ~/.profile.local

# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set ft=sh:

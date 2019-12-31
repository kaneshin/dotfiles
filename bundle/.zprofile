# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 01-Jan-2020.

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
export LOCALSDK="$LOCALROOT/sdk"

SYSTEM_NAME=$(uname -s | tr '[:upper:]' '[:lower:]')
HARDWARE_NAME=$(uname -m | tr '[:upper:]' '[:lower:]')


if which brew > /dev/null 2>&1; then
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

# setup vim
if [ -d "$HOME/.vim" ]; then
  export VIM_ROOT="$HOME/.vim"
  if [ ! -f "$VIM_ROOT/autoload/plug.vim" ]; then
    if which curl > /dev/null 2>&1; then
      echo "Installing plug.vim in $VIM_ROOT/autoload"
      curl -sfLo "$VIM_ROOT/autoload/plug.vim" --create-dirs \
        'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    fi
  fi
fi

# setup rust
if [ -d "$HOME/.cargo" ]; then
  export CARGO_ROOT="$HOME/.cargo"
  if [[ ":${PATH}:" != *:"${CARGO_ROOT}/bin":* ]]; then
    export PATH="$CARGO_ROOT/bin:$PATH"
  fi
fi

# setup rbenv
if [ -d "$HOME/.rbenv" ]; then
  export RBENV_ROOT="$HOME/.rbenv"
  if [[ ":${PATH}:" != *:"${RBENV_ROOT}/bin":* ]]; then
    export PATH="$RBENV_ROOT/bin:$PATH"
    which rbenv > /dev/null 2>&1 && eval "$(rbenv init -)"
  fi
fi

# setup pyenv
if [ -d "$HOME/.pyenv" ]; then
  export PYTHON_CONFIGURE_OPTS="--enable-shared"
  export PYENV_ROOT="$HOME/.pyenv"
  if [[ ":${PATH}:" != *:"${PYENV_ROOT}/bin":* ]]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
    which pyenv > /dev/null 2>&1 && eval "$(pyenv init -)"
  fi
fi

# setup goenv
if [ -d "$HOME/.goenv" ]; then
  export GOENV_ROOT="$HOME/.goenv"
  if [[ ":${PATH}:" != *:"${GOENV_ROOT}/bin":* ]]; then
    export PATH="$GOENV_ROOT/bin:$PATH"
    which goenv > /dev/null 2>&1 && eval "$(goenv init -)"
  fi
fi

# setup nodenv
if [ -d "$HOME/.nodenv" ]; then
  export NODENV_ROOT="$HOME/.nodenv"
  if [[ ":${PATH}:" != *:"${NODENV_ROOT}/bin":* ]]; then
    export PATH="$NODENV_ROOT/bin:$PATH"
    which nodenv > /dev/null 2>&1 && eval "$(nodenv init -)"
  fi
fi

# setup go-lang
export GOPATH="$LOCALROOT"
export GOBIN="$LOCALBIN"
if [[ ":${PATH}:" != *:"${GOBIN}":* ]]; then
  export PATH="$GOBIN:$PATH"
fi
export GO15VENDOREXPERIMENT=1
export GO111MODULE=on

# setup ghq
which ghq > /dev/null 2>&1 && export GHQ_ROOT=$LOCALSRC

# setup gcloud
if [ ! -d "$LOCALSDK/google-cloud-sdk" ]; then
    if which curl > /dev/null 2>&1; then
      local version='274.0.1'
      local archive="$TMPDIR/cloud-sdk.tar.gz"
      echo "Installing Cloud SDK version [$version] in $LOCALSDK"
      curl -sfL \
        "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-$version-$SYSTEM_NAME-$HARDWARE_NAME.tar.gz" \
        | tar zxf - -C $LOCALSDK
      echo "To finish the installation of your SDK version [$version], run:\n$ $LOCALSDK/google-cloud-sdk/install.sh"
    fi
fi
if [ -d "$LOCALSDK/google-cloud-sdk" ]; then
  export CLOUDSDK_ROOT="$LOCALSDK/google-cloud-sdk"
  if [[ ":${PATH}:" != *:"${CLOUDSDK_ROOT}/bin":* ]]; then
    export PATH="$CLOUDSDK_ROOT/bin:$PATH"
  fi
  # The next line updates PATH for the Google Cloud SDK.
  if [ -f "$CLOUDSDK_ROOT/path.zsh.inc" ]; then . "$CLOUDSDK_ROOT/path.zsh.inc"; fi
  # The next line enables shell command completion for gcloud.
  if [ -f "$CLOUDSDK_ROOT/completion.zsh.inc" ]; then . "$CLOUDSDK_ROOT/completion.zsh.inc"; fi
fi
if which gcloud > /dev/null 2>&1; then
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

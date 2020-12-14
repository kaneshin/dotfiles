# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 14-Dec-2020.

# system-wide environment settings for zsh(1)
if [ -x /usr/libexec/path_helper ]; then
  PATH=""
  eval `/usr/libexec/path_helper -s`
fi

# local directory
export LOCALROOT="$HOME/local"
export LOCALSRC="$LOCALROOT/src"
[ ! -d "$LOCALSRC" ] && mkdir -p $LOCALSRC
export LOCALBIN="$LOCALROOT/bin"
[ ! -d "$LOCALBIN" ] && mkdir -p $LOCALBIN
export LOCALSDK="$LOCALROOT/sdk"
[ ! -d "$LOCALSDK" ] && mkdir -p $LOCALSDK

SYSTEM_NAME=$(uname -s | tr '[:upper:]' '[:lower:]')
HARDWARE_NAME=$(uname -m | tr '[:upper:]' '[:lower:]')

# setup homebrew
if which brew > /dev/null 2>&1; then
  # setup for macOS
  GNUBIN_PATH="`brew --prefix coreutils`/libexec/gnubin"
  if [ -d "$GNUBIN_PATH" ]; then
    export PATH="$GNUBIN_PATH:$PATH"
    export MANPATH="`brew --prefix coreutils`/libexec/gnuman:$MANPATH"
  fi
fi

# setup macports
if [ -d "/opt/local/bin" ]; then
  export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
  export DISPLAY=:0
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
  export CARGO_HOME="$HOME/.cargo"
  if [[ ":${PATH}:" != *:"${CARGO_HOME}/bin":* ]]; then
    export PATH="$CARGO_HOME/bin:$PATH"
  fi
  if [ -d "$HOME/.rustup" ]; then
    export RUSTUP_HOME="$HOME/.rustup"
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

# setup go-lang
export GOPATH="$LOCALROOT"
export GOBIN="$LOCALBIN"
if [[ ":${PATH}:" != *:"${GOBIN}":* ]]; then
  export PATH="$GOBIN:$PATH"
fi
export GOROOT="$HOME/go"
export GOROOTBIN="$GOROOT/bin"
if [[ ":${PATH}:" != *:"${GOROOTBIN}":* ]]; then
  export PATH="$GOROOTBIN:$PATH"
fi
export GO15VENDOREXPERIMENT=1
export GO111MODULE=on

# setup ghq
if which ghq > /dev/null 2>&1; then
  export GHQ_ROOT=$LOCALSRC
fi

# setup tmux
if which tmux > /dev/null 2>&1; then
  if [ -n "$TMUX" ]; then
    if which reattach-to-user-namespace > /dev/null 2>&1; then
      if [ "$TMUX_REATTACHED" != 'on' ]; then
        echo Running reattach-to-user-namespace to enable copy and paste on macOS
        export TMUX_REATTACHED='on'
        reattach-to-user-namespace -l $SHELL
        echo Exited reattach-to-user-namespace
      fi
    fi
  fi
fi

# setup gcloud
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

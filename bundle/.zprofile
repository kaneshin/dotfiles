# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 21-Oct-2022.

# system-wide environment settings for zsh(1)
if [ -x /usr/libexec/path_helper ]; then
  PATH=""
  eval `/usr/libexec/path_helper -s`
fi

# local directory
export LOCAL_ROOT="${HOME%/}"
export LOCAL_SRC="$LOCAL_ROOT/src"
[ ! -d "$LOCAL_SRC" ] && mkdir -p $LOCAL_SRC
export LOCAL_BIN="$LOCAL_ROOT/bin"
[ ! -d "$LOCAL_BIN" ] && mkdir -p $LOCAL_BIN
export LOCAL_SDK="$LOCAL_ROOT/sdk"
[ ! -d "$LOCAL_SDK" ] && mkdir -p $LOCAL_SDK
export WORKSPACE_ROOT="$HOME/workspace"
[ ! -d "$WORKSPACE_ROOT" ] && mkdir -p $WORKSPACE_ROOT

SYSTEM_NAME=$(uname -s | tr '[:upper:]' '[:lower:]')
HARDWARE_NAME=$(uname -m | tr '[:upper:]' '[:lower:]')

# setup homebrew
if [ -f "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if which brew > /dev/null 2>&1; then
  if brew --prefix coreutils > /dev/null 2>&1; then
    LIBEXEC_PATH="`brew --prefix coreutils`/libexec"
    export PATH="$LIBEXEC_PATH/gnubin:$PATH"
    export MANPATH="$LIBEXEC_PATH/gnuman:$MANPATH"
  fi
fi

# setup macports
if [ -d "/opt/local/bin" ]; then
  export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
  export DISPLAY=:0
  GNUBIN_PATH="/opt/local/libexec/gnubin"
  if [ -d "$GNUBIN_PATH" ]; then
    export PATH="$GNUBIN_PATH:$PATH"
    export MANPATH="$GNUBIN_PATH/man:$MANPATH"
  fi
fi

# setup local dir
if [[ ":${PATH}:" != *:"${LOCAL_BIN}":* ]]; then
  export PATH="$LOCAL_BIN:$PATH"
fi

# setup dotfiles
if [ -d "$LOCAL_SRC/github.com/kaneshin/dotfiles" ]; then
  export DOTFILES_ROOT="$LOCAL_SRC/github.com/kaneshin/dotfiles"
  if [[ ":${PATH}:" != *:"${DOTFILES_ROOT}/bin":* ]]; then
    export PATH="$DOTFILES_ROOT/bin:$PATH"
  fi
fi

# setup go
export GOPATH="$LOCAL_ROOT"
export GOBIN="$LOCAL_BIN"
if [[ ":${PATH}:" != *:"${GOBIN}":* ]]; then
  export PATH="$GOBIN:$PATH"
fi
export GOROOT="$HOME/go"
export GOROOTBIN="$GOROOT/bin"
if [[ ":${PATH}:" != *:"${GOROOTBIN}":* ]]; then
  export PATH="$GOROOTBIN:$PATH"
fi
export GOPROXY="https://proxy.golang.org,direct"
export GO15VENDOREXPERIMENT=1
export GO111MODULE=on

# setup rust
if [ -d "$HOME/.cargo" ]; then
  export CARGO_HOME="$HOME/.cargo"
  if [[ ":${PATH}:" != *:"${CARGO_HOME}/bin":* ]]; then
    export PATH="$CARGO_HOME/bin:$PATH"
  fi
fi

# setup ghq
if which ghq > /dev/null 2>&1; then
  export GHQ_ROOT=$LOCAL_SRC
fi

# setup fzf
if [ -d "$HOME/.fzf" ]; then
  export FZF_ROOT="$HOME/.fzf"
  export FZF_BIN="$FZF_ROOT/bin"
  if [[ ":${PATH}:" != *:"${FZF_BIN}":* ]]; then
    export PATH="$FZF_BIN:$PATH"
  fi
fi


# local
[ -f ~/.profile.local ] && source ~/.profile.local

# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set ft=sh:

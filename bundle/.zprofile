# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 01-Jan-2021.

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

# setup go-lang
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
export GO15VENDOREXPERIMENT=1
export GO111MODULE=on

# setup ghq
if which ghq > /dev/null 2>&1; then
  export GHQ_ROOT=$LOCAL_SRC
fi

# local
[ -f ~/.profile.local ] && source ~/.profile.local

# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set ft=sh:

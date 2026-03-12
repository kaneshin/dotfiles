# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 12-Mar-2026.

# system-wide environment settings for zsh(1)
if [ -x /usr/libexec/path_helper ]; then
  PATH=""
  eval `/usr/libexec/path_helper -s`
fi

# local directory
export LOCAL_ROOT="${HOME%/}"
export LOCAL_SRC="$LOCAL_ROOT/src"
[ ! -d "$LOCAL_SRC" ] && mkdir -p $LOCAL_SRC
export LOCAL_BIN="$LOCAL_ROOT/.local/bin"
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

### Programming Language ###

## setup go
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

## setup python
if [ -d "$HOME/.pyenv" ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PYENV_BIN="$PYENV_ROOT/bin"
  if [ -d "$PYENV_BIN" ]; then
    if [[ ":${PATH}:" != *:"${PYENV_BIN}":* ]]; then
      export PATH="$PYENV_BIN:$PATH"
      eval "$(pyenv init -)"
    fi
  fi
fi

## setup rust
if [ -d "$HOME/.cargo" ]; then
  export CARGO_HOME="$HOME/.cargo"
  export CARGO_BIN="$CARGO_HOME/bin"
  if [[ ":${PATH}:" != *:"${CARGO_BIN}":* ]]; then
    export PATH="$CARGO_BIN:$PATH"
  fi
fi

## setup pnpm
if which pnpm > /dev/null 2>&1; then
  export PNPM_HOME="$HOME/.pnpm"
  [ ! -d "$PNPM_HOME" ] && mkdir -p $PNPM_HOME
  if [[ ":${PATH}:" != *:"${PNPM_HOME}":* ]]; then
    export PATH="$PNPM_HOME:$PATH"
  fi
fi

### Dev Tools ###

function brewport_install() {
  if which brew > /dev/null 2>&1; then
    brew install "$@"
  elif which port > /dev/null 2>&1; then
    port install "$@"
  fi
}

## setup jq
if ! which jq > /dev/null 2>&1; then
  brewport_install jq
fi

## setup ghq
if ! which ghq > /dev/null 2>&1; then
  brewport_install ghq
fi
if which ghq > /dev/null 2>&1; then
  export GHQ_ROOT=$LOCAL_SRC
fi

## setup fd
if ! which fd > /dev/null 2>&1; then
  brewport_install fd
fi

## setup fzf
if ! which fzf > /dev/null 2>&1; then
  brewport_install fzf
fi

## setup mmv
if ! which mmv > /dev/null 2>&1; then
  brewport_install itchyny/tap/mmv
fi

## setup rancher desktop
if [ -d "$HOME/.rd" ]; then
  export RD_ROOT="$HOME/.rd"
  export RD_BIN="$RD_ROOT/bin"
  if [[ ":${PATH}:" != *:"${RD_BIN}":* ]]; then
    export PATH="$RD_BIN:$PATH"
  fi
fi

# local
[ -f ~/.profile.local ] && source ~/.profile.local

# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set ft=sh:

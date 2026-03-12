#!/usr/bin/env bash

readonly SGR_RESET="\033[0m"
readonly SGR_BOLD="\033[1m"
readonly SGR_FAINT="\033[2m"
readonly SGR_UNDERLINE="\033[4m"
readonly SGR_RED="\033[31m"
readonly SGR_CYAN="\033[36m"

log() {
  printf "  ${SGR_CYAN}%10s${SGR_RESET}: ${SGR_FAINT}%s${SGR_RESET}\n" "$1" "$2"
}

abort() {
  >&2 printf "\n  ${SGR_RED}Error: %s${SGR_RESET}\n\n" "$*" && exit 1
}

readonly VIM_ROOT="$HOME/.vim"
readonly VIMPLUG_ROOT="$VIM_ROOT/autoload/plug.vim"

install() {
  if ! which curl > /dev/null 2>&1; then
    abort "Install cURL"
  fi

  readonly VIMPLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

  log "installing" "vim-plug/plug.vim"
  log "fetch" "$VIMPLUG_URL"
  curl -sfLo $VIMPLUG_ROOT --create-dirs $VIMPLUG_URL
  log "installed" "$VIMPLUG_ROOT"
}

uninstall() {
  echo "Uninstall $VIMPLUG_ROOT"
  while true; do
    read -n 1 -p "Continue? [y/N] " yn
    echo
    case "$(echo ${yn:-n} | tr "[:upper:]" "[:lower:]")" in
      "y")
        log "rm" "$VIMPLUG_ROOT"
        rm -f $VIMPLUG_ROOT
        break
        ;;
      "n")
        exit 1
        ;;
    esac
  done
}

verify() {
  if [ -f "$VIMPLUG_ROOT" ]; then
    log "verified" "vim-plug is installed => $VIMPLUG_ROOT"
  else
    abort "vim-plug not installed"
  fi
}

case "$1" in
  "install") install ;;
  "uninstall") verify && uninstall ;;
  "verify") verify ;;
  *) abort "Unexpected sub-command"
esac

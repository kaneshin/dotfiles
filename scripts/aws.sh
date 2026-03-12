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

readonly TMP_DIR=${TMPDIR:-/tmp}

install() {
  if ! which curl > /dev/null 2>&1; then
    abort "Install cURL"
  fi

  readonly AWSCLIV2_URL="https://awscli.amazonaws.com/AWSCLIV2.pkg"

  log "installing" "AWS CLI version 2"
  log "fetch" "$AWSCLIV2_URL"
  curl -sLS "$AWSCLIV2_URL" -o "${TMP_DIR}AWSCLIV2.pkg"
  sudo installer -pkg "${TMP_DIR}AWSCLIV2.pkg" -target /
  log "installed" "aws"
}

uninstall() {
  echo "Uninstall $(which aws)"
  while true; do
    read -n 1 -p "Continue? [y/N] " yn
    echo
    case "$(echo ${yn:-n} | tr "[:upper:]" "[:lower:]")" in
      "y")
        p=$(which aws)
        log "rm" "rm -rf $p"
        log "rm" "rm -rf ${p}_completer"
        log "rm" "rm -rf /usr/local/aws-cli"
        rm -rf "$p"
        rm -rf "${p}_completer"
        sudo rm -rf "/usr/local/aws-cli"
        break
        ;;
      "n")
        exit 1
        ;;
    esac
  done
}

verify() {
  if which aws > /dev/null 2>&1; then
    log "verified" "aws --version => $(aws --version)"
  else
    abort "aws not installed"
  fi
}

case "$1" in
  "install") install ;;
  "uninstall") verify && uninstall ;;
  "verify") verify ;;
  *) printf "Unexpected sub-command"
esac

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

install() {
  if ! which curl > /dev/null 2>&1; then
    abort "Install cURL"
  fi

  readonly N_URL="https://raw.githubusercontent.com/tj/n/master/bin/n"
  readonly N_ROOT="$PREFIX/bin/n"

  log "installing" "tj/n"
  log "fetch" "$N_URL"
  curl -sfLo $N_ROOT --create-dirs $N_URL
  log "chmod" "$N_ROOT"
  chmod a+x $N_ROOT
  log "installed" "$N_ROOT"
}

uninstall() {
  echo "Uninstall $(which n)"
  while true; do
    read -n 1 -p "Continue? [y/N] " yn
    echo
    case "$(echo ${yn:-n} | tr "[:upper:]" "[:lower:]")" in
      "y")
        log "rm" "rm -rf $(which n)"
        rm -f $(which n)
        break
        ;;
      "n")
        exit 1
        ;;
    esac
  done
}

update() {
  echo "$(which n) will be reinstalled (uninstall && install)"

  path=$(which n)
  PREFIX=${path%/bin/n}
  uninstall && install
}

info() {
  cat <<-EOF
# make cache folder (if missing) and take ownership
sudo mkdir -p /usr/local/n
sudo chown -R \$(whoami) /usr/local/n

# make sure the required folders exist (safe to execute even if they already exist)
sudo mkdir -p /usr/local/bin /usr/local/lib /usr/local/include /usr/local/share
# take ownership of node install destination folders
sudo chown -R \$(whoami) /usr/local/bin /usr/local/lib /usr/local/include /usr/local/share
EOF
}

verify() {
  if which n > /dev/null 2>&1; then
    log "verified" "n --version => $(n --version)"
  else
    abort "n not installed"
  fi
}

PREFIX="${PREFIX-/usr/local}"
PREFIX=${PREFIX%/}

case "$1" in
  "install") install ;;
  "uninstall") verify && uninstall ;;
  "update") verify && update ;;
  "verify") verify ;;
  "info") info ;;
  *) printf "Unexpected sub-command"
esac

# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 04-May-2016.

unset GITUTIL_STATUS
function switch_gitutil_status() {
  case $1 in
    'on' )
      GITUTIL_STATUS=true
      ;;
    'off' )
      GITUTIL_STATUS=false
      ;;
  esac
}
switch_gitutil_status on
alias gitst='switch_gitutil_status'

function _git_short_status() {
  git status -s 2> /dev/null
}

function _git_branch_name() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function git_short_status() {
  $GITUTIL_STATUS && _git_short_status
}

function git_root_dir_name() {
  basename $(cd ./`git rev-parse --show-cdup`;pwd)
}

function git_info() {
  name=`_git_branch_name`
  if [ ! "$name" = "" ]; then
    echo '('`git_root_dir_name`":$name)"
  fi
}

# gi
function gi() { curl -L -s https://www.gitignore.io/api/$@ ;}

# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set ft=sh:

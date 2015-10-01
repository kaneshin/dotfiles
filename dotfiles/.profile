# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set fdm=marker:
# vim:set ft=sh:
#
# File:        .profile
# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 01-Oct-2015.
# ============================================================

# Export environment variables
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LESSCHARSET=UTF-8
export LSCOLORS=gxfxcxdxbxegedabagacad
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

# PATH
export PATH=/usr/local/bin:${PATH}
export PATH=${HOME}/local/bin:${PATH}

# DOTFILES
if [ -f ${HOME}/.profile ]; then
  export DOTFILES=$(dirname $(readlink -n ${HOME}/.profile))
fi

if [ -f ${HOME}/.sh.function ]; then
  . ${HOME}/.sh.function
fi

_read_type ".profile"

_read_local ".profile"

rbenv=`which rbenv 2>&1`
if [[ "${?}" = "0" ]]; then
  eval "$(rbenv init -)"
fi

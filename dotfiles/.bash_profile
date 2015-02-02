# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set fdm=marker:
#
# File:        .bash_profile
# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 02-Feb-2015.
# ============================================================

# common
if [ -f ~/.profile ]; then
  . ~/.profile
fi

# local
if [ ! -f ~/.bash_profile.local ]; then
  touch ~/.bash_profile.local
fi
if [ -f ~/.bash_profile.local ]; then
  . ~/.bash_profile.local
fi


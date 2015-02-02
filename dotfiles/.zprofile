# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set fdm=marker:
#
# File:        .zprofile
# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 02-Feb-2015.
# ============================================================

# common
if [ -f ~/.profile ]; then
  . ~/.profile
fi

# local
if [ ! -f ~/.zprofile.local ]; then
  touch ~/.zprofile.local
fi
if [ -f ~/.zprofile.local ]; then
  . ~/.zprofile.local
fi


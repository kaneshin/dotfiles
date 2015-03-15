# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set fdm=marker:
# vim:set ft=sh:
#
# File:        .zprofile
# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 15-Mar-2015.
# ============================================================

if [ -f ${HOME}/.sh.function ]; then
  . ${HOME}/.sh.function
fi

# source .profile
_read_file ".profile"

# source .zprofile
_read_local ".zprofile"


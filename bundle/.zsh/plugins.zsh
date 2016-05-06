# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 06-May-2016.

# setup z
[ -f $LOCALSRC/github.com/rupa/z/z.sh ] && . $LOCALSRC/github.com/rupa/z/z.sh

# setup gi
function gi() { curl -L -s https://www.gitignore.io/api/$@ ;}

# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set ft=sh:

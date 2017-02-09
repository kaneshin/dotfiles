# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 09-Feb-2017.

shell=$(echo ${0/*plugins./})

# setup z
[ -f $LOCALSRC/github.com/rupa/z/z.sh ] && . $LOCALSRC/github.com/rupa/z/z.sh

# setup direnv
which direnv > /dev/null 2>&1 && eval "$(direnv hook $shell)"

# setup gi
function gi() { curl -L -s https://www.gitignore.io/api/$@ ;}

# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set ft=sh:

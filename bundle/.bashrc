# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 04-Jun-2020.

# size of history
function share_history {
    history -a
    history -c
    history -r
}
shopt -u histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# load $HOME/.bash/*
if [ -d $HOME/.bash ]; then
  for i in `ls -1 $HOME/.bash`; do
    src=$HOME/.bash/$i; [ -f $src ] && . $src
  done
fi

# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set ft=sh:

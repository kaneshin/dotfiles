# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 04-May-2016.

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

PS1="
\033[37m\$(git_short_status) \033[0m\]
\033[36m[\u@\h] \033[33m\w \\033[31m$(git_info)\033[0m\]
\033[39m\$ \033[0m\]"

# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set ft=sh:

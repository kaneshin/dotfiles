# vim:set fdm=marker:
#
# File:        .bashrc
# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 08-Nov-2012.

# source common shell run command
source ~/.shrc.common

# size of history
function share_history {
    history -a
    history -c
    history -r
}
PROMPT_COMMAND='share_history'
HISTSIZE=5000
HISTFILESIZE=5000
shopt -u histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

PS1="\[\033[36m(\u@\h) \033[33m\w\\n\033[39m\$ \033[0m\]"


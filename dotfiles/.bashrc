# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set fdm=marker:
#
# File:        .bashrc
# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 21-Dec-2014.
# ============================================================

# common
[ -f ~/.shrc ] && source ~/.shrc

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

PS1="
\033[37m\$(parse_git_status) \033[0m\]
\033[36m[\u@\h] \033[33m\w \033[0m\]
\033[39m\$\033[35m\$(parse_git_branch) \033[0m\]"

# local
[ -f ~/.bashrc.local ] && source ~/.bashrc.local


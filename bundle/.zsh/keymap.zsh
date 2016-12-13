# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 13-Dec-2016.

# make key map
function _ce() {
  cd ../
  zle reset-prompt
}
zle -N _ce

# function _clear_screen() {
#   clear
#   ls -alh | grep --color=none "^d" && ls -la | grep -v "^d\|^total"
#   zle reset-prompt
#   zle -R
# }
# zle -N _clear_screen

bindkey "^O" _ce
# bindkey "^L" _clear_screen

# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set ft=sh:

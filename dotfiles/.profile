# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set fdm=marker:
#
# File:        .profile
# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 21-Dec-2014.
# ============================================================

# Export environment variables
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LESSCHARSET=UTF-8
export LSCOLORS=gxfxcxdxbxegedabagacad
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

# PATH
export PATH=/usr/local/bin:$PATH
export PATH=$HOME/local/bin:$PATH

# OS
case $OSTYPE in
  darwin* )
    [ -f ~/.profile.darwin ] && source ~/.profile.darwin
    ;;
  linux* )
    [ -f ~/.profile.linux ] && source ~/.profile.linux
    ;;
esac

# local
[ -f ~/.profile.local ] && source ~/.profile.local


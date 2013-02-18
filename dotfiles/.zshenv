# vim:set fdm=marker:
#
# File:        .zshenv
# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 14-Feb-2013.

export PATH=/usr/local/bin:$PATH
export PATH=/usr/texbin:$PATH
export PATH=$HOME/local/bin:$PATH

# Export environment variables
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LESSCHARSET=UTF-8
export LSCOLORS=gxfxcxdxbxegedabagacad
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

# ruby
# Add RVM to PATH for scripting
# PATH=$PATH:$HOME/.rvm/bin
# source $HOME/.rvm/scripts/rvm
# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# perl
[[ -s "$HOME/perl5/perlbrew/etc/bashrc" ]] && source ~/perl5/perlbrew/etc/bashrc

# node.js
export PATH=$HOME/.nodebrew/current/bin:$PATH

export ANDROID_HOME=/Applications/adt-bundle-mac-x86_64/sdk/

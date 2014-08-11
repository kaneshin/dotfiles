# vim:set fdm=marker:
#
# File:        .bash_profile
# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 11-Aug-2014.

export PATH=/usr/local/bin:$PATH
export PATH=/usr/texbin:$PATH
export PATH=$HOME/local/bin:$PATH

export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home
export M2_HOME=/usr/share/maven

export ANDROID_HOME=/Users/kaneshin/local/sdk/android-sdk-macosx
export ANDROID_SDK=$ANDROID_HOME
export ANDROID_TOOLS=$ANDROID_HOME/tools

export PATH=$PATH:$ANDROID_TOOLS
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$M2_HOME/bin

export GOROOT=/usr/local/go
export GOPATH=~/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# Export environment variables
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LESSCHARSET=UTF-8
export LSCOLORS=gxfxcxdxbxegedabagacad
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'


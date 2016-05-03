export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LESSCHARSET=UTF-8
export LSCOLORS=gxfxcxdxbxegedabagacad
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

export LOCALROOT="$HOME/local"
export LOCALSRC="$LOCALROOT/src"
export LOCALBIN="$LOCALROOT/bin"

export PATH="$LOCALBIN:/usr/local/bin:$PATH"

# Setup dotfiles
if [ -d "$HOME/develop/dotfiles" ]; then
  export DOTFILES_ROOT="$HOME/develop/dotfiles"
  export PATH="$DOTFILES_ROOT/bin:$PATH"
fi

# Setup rbenv
if [ -d "$HOME/.rbenv" ]; then
  export RBENV_ROOT="$HOME/.rbenv"
  export PATH="$RBENV_ROOT/bin:$PATH"
  which rbenv > /dev/null && eval "$(rbenv init -)"
fi

# Setup pyenv
if [ -d "$HOME/.pyenv" ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  which pyenv > /dev/null && eval "$(pyenv init -)"
fi

# Setup goenv
if [ -d "$HOME/.goenv" ]; then
  export GOENV_ROOT="$HOME/.goenv"
  export PATH="$GOENV_ROOT/bin:$PATH"
  which goenv > /dev/null && eval "$(goenv init -)"
fi

# Setup nodenv
if [ -d "$HOME/.nodenv" ]; then
  export NODENV_ROOT="$HOME/.nodenv"
  export PATH="$NODENV_ROOT/bin:$PATH"
  which nodenv > /dev/null && eval "$(nodenv init -)"
fi

# Setup golang
export PATH=$GOROOT/bin:$PATH
export GOPATH="$LOCALROOT"
export GOBIN="$LOCALBIN"
# export PATH="$GOBIN:$PATH"
export GO15VENDOREXPERIMENT=1

# Setup go_appengine
# export PATH=$PATH:/usr/local/share/google/go_appengine/


# Setup z
[ -f $LOCALSRC/github.com/rupa/z/z.sh ] && . $LOCALSRC/github.com/rupa/z/z.sh

# source ~/.zplug/init.zsh
# zplug "zsh-users/zsh-history-substring-search"
# zplug "zsh-users/zsh-syntax-highlighting", nice:10
# # zplug "~/.zsh", from:local
# if ! zplug check; then
#   zplug install
# fi
# zplug load

# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set ft=sh:

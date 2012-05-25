# vim:set ts=8 sts=2 sw=2 tw=0:
#==========================================================================
# File: .zshrc
# Last Change: 17-Mar-2012.
# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
#===========================================================================

#====================
# basic setting
# export LANG=ja_JP.UTF-8
export LANG="en_US.UTF-8"
bindkey -v # vi key map
# bindkey -e # emacs key map

#====================
# history
export HISTFILE=~/.zsh_history
export HISTSIZE=3000
export SAVEHIST=3000
setopt append_history
setopt extended_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify
setopt share_history

autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

#====================
# Display
PS1='%{]0;%/
[32m%}(%n@%m)[%h] %{[33m%}%~%{[0m%}
$ '
export LSCOLORS=gxfxcxdxbxegedabagacad

#====================
# options
setopt auto_pushd
setopt auto_cd
setopt correct
setopt cdable_vars
setopt complete_aliases
setopt list_packed
setopt list_types
setopt pushd_ignore_dups
setopt auto_param_slash
setopt mark_dirs
setopt auto_menu
setopt auto_param_keys
setopt interactive_comments
setopt magic_equal_subst
setopt complete_in_word
setopt always_last_prompt
setopt print_eight_bit
setopt extended_glob
setopt globdots

#====================
# others
autoload -Uz compinit
compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' use-cache true
zstyle ':completion:*' list-colors ${(s.:.)LSCOLORS}
zstyle ':completion:*:default' menu select=3

#====================
# alias
alias sl="ls"
alias ls="ls -G"
alias ls='ls -F'
alias la='ls -a'
alias ll='ls -la'
alias ce='cd ../'
alias pvim='vim -u $HOME/.pvimrc'

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

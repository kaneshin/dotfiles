# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set foldmethod=marker foldmarker={{{,}}} :
#===========================================================================
# File: .zshrc
# Last Change: 18-Oct-2011.
# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
#===========================================================================

##############################
# set lang
##############################
# {{{
export LANG=ja_JP.UTF-8
case ${UID} in
0)
    LANG=C
    ;;
esac
# }}}

##############################
# basic setting
##############################
# {{{
autoload -Uz compinit
compinit
autoload -Uz colors
colors
# }}}

##############################
# options
##############################
# {{{
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
# }}}

##############################
# completions
##############################
# {{{
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' use-cache true
zstyle ':completion:*:default' menu select=3
# }}}

##############################
# history
##############################
# {{{
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
# }}}
#
##############################
# Node.js
##############################
# {{{
PATH=$PATH:~/.nave
alias nave='nave.sh'
# }}}

##############################
# key mapping
##############################
# {{{
# bindkey -e # emacs key map
bindkey -v # vi key map
# }}}
#
##############################
# alias
##############################
# {{{
alias ls='ls -F'
alias la='ls -a'
alias ll='ls -la'
# }}}

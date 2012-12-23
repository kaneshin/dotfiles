# vim:set fdm=marker:
#
# File:        .zshrc
# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 23-Dec-2012.

# source common shell run command
source ~/.shrc.common

# bindkey -v # vi key map
bindkey -e # emacs key map

# history
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
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

# Display
PS1='%{]0;%/
[32m%}(%n@%m)[%h] %{[33m%}%~%{[0m%}
(  ՞ਊ ՞)☞  '
export LSCOLORS=gxfxcxdxbxegedabagacad

case "${TERM}" in
kterm*|xterm)
    precmd()
    {
        echo -ne "\033]0;${USER}@${HOST}\007"
    }
    ;;
esac

export LSCOLORS=gxfxxxxxcxxxxxxxxxgxgx
export LS_COLORS='di=01;36:ln=01;35:ex=01;32'
zstyle ':completion:*' list-colors 'di=36' 'ln=35' 'ex=32'

# 
setopt auto_pushd
setopt auto_cd

# check command
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

# others
autoload -Uz compinit
compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' use-cache true
zstyle ':completion:*' list-colors ${(s.:.)LSCOLORS}
zstyle ':completion:*:default' menu select=3


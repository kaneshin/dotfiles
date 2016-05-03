# alias
## ls command
alias ls='ls -F'
alias la='ls -a'
alias ll='ls -la'
alias sl="ls"
alias l='ls -la'
alias l.='ls -d .*'

## cd command
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ce='cd ..'
alias cd..='cd ..'

## grep command
alias grep='grep --color=always'
alias ngrep='grep -n --color=always'
alias fgrep='fgrep --color=always'
alias egrep='egrep --color=always'

## mkdir command
alias mkdir='mkdir -p'

## less command
alias less='less -R'

## useful command
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'

# use key map like emacs
bindkey -e

# history settings
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000
# append history when exit shell
setopt append_history

# extended format for history
setopt extended_history

# beep when no history
unsetopt hist_beep

# delete duplicated history when register command
setopt hist_ignore_all_dups

# don't register history if the command with leading spaces
setopt hist_ignore_space

# remove extra spaces from command
setopt hist_reduce_blanks

# don't run command when matching
setopt hist_verify

# share history with all zsh process
setopt share_history

# make key map for history search
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

# make key map
function _git_commit() {
  git commit -m "${BUFFER}"
  zle reset-prompt
}
zle -N _git_commit

function _ce() {
  cd ../
  zle reset-prompt
}
zle -N _ce

function _clear_screen() {
  clear
  ls -alh | grep --color=none "^d" && ls -la | grep -v "^d\|^total" 
  zle reset-prompt
  zle -R
}
zle -N _clear_screen

bindkey "^Y" _git_commit
bindkey "^O" _ce
bindkey "^V" _ce
bindkey "^L" _clear_screen

# prompt settings
# variable expansion for prompt
setopt prompt_subst

# expansion of percent for prompt variable
setopt prompt_percent

# output CR when generating characters without trailing CR into prompt
setopt prompt_cr

# visible CR when output CR by prompt_cr
setopt prompt_sp

# PROMPT1
PS1="%{[0m%}
%{[37m%}\$(parse_git_status)%{[0m%}
%{[32m%}[%n@%m] %{[33m%}%~%{[0m%}
%(?|%{[36m%}( ^o^%) <|%{[31m%}(;^o^%) <)%{[35m%}\$(parse_git_branch) %{[0m%}"

# PROMPT2
PS2="%_> "

# PROMPT for correct
SPROMPT="zsh: Did you mean: %{[4m[31m%}%r%{[14m[0m%} [nyae]? "


# completion settings
autoload -Uz compinit
compinit -u
# don't create new prompt
setopt always_last_prompt

# do like putting * on cursor when complement
setopt complete_in_word

# output list automatically
setopt auto_list

# completion when pushed key for complement twice
unsetopt bash_auto_list

# move a command of candidates
setopt auto_menu

# set a command immediately
unsetopt menu_complete

# don't substring alias when complement
setopt complete_aliases

# beep when no result
unsetopt list_beep

# reduce line of list
setopt list_packed

# show trailing character of file
setopt list_types

# set candidate immediately
# zstyle ':completion:*' menu true

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' use-cache true
zstyle ':completion:*:default' menu select=3
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# color settings
autoload -U colors: colors

# auto change directory
setopt auto_cd

# correct command
setopt correct

setopt auto_pushd
setopt cdable_vars
setopt pushd_ignore_dups
setopt auto_param_slash
setopt mark_dirs
setopt auto_param_keys
setopt interactive_comments
setopt magic_equal_subst
setopt print_eight_bit
setopt extended_glob
setopt globdots

export DIRSTACKSIZE=100
setopt AUTO_PUSHD

autoload -Uz compinit && compinit

zstyle ':completion:*' menu select
zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*:descriptions' format '%BCompleting%b %U%d%u'


_set_gitst()
{
  case $1 in
    on )
      GITST=1
      ;;
    off )
      GITST=0
      ;;
  esac
}

parse_git_status()
{
  if [ $GITST -ne 0 ]; then
    git status -s 2> /dev/null
  fi
}

parse_git_branch()
{
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'
}

_set_gitst on
alias gitst='_set_gitst'

gi()
{
  curl https://www.gitignore.io/api/$@ ;
}

# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set ft=sh:

# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 09-Jul-2025.

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
alias fgrep='fgrep --color=none -l'

## mkdir command
alias mkdir='mkdir -p'

## less command
alias less='less -R'

## useful command
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'
# alias peco='peco --initial-filter=Fuzzy'

# claude alias
if [ -x ~/.claude/local/claude ]; then
  alias claude='~/.claude/local/claude'
fi

# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set ft=sh:

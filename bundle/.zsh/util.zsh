# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 25-Jun-2016.

function ssh-pubkey() {
  user=$(git config --get github.user)
  if [ $user = "" ]; then
    echo 'No Content: git config --get github.user'
    return 1
  fi
  curl -L -s "https://github.com/$user.keys"
}

function goimp() {
  grep -e "\t\"\(github\|bitbucket\|golang\|google\).*\"$" . -R --color=none | grep -v -e "\.git" -e "README" -e "wercker" -e "ansible" | cut -f2 | sort -u
}

# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set ft=sh:

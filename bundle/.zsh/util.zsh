# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 06-May-2016.

function ssh-pubkey() {
  user=$(git config --get github.user)
  if [ $user = "" ]; then
    echo 'No Content: git config --get github.user'
    return 1
  fi
  curl -L -s "https://github.com/$user.keys"
}

# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set ft=sh:

# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 26-Dec-2016.

function jobs_await() {
  spinners=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local pid="$1"
  while true; do
    for spinner in ${spinners[@]}; do
      printf "  $spinner  \r" > /dev/stderr
      sleep 0.05
    done
    if ! jobs -rp | grep "$pid" > /dev/null; then
      break
    fi
  done
}

function get_name() {
  myths=(`cat $DOTFILES_ROOT/dict/myths-legends`)
  local len=${#myths[*]}
  local num=`expr $RANDOM % $len`
  echo ${myths[$num]}
}

# ===== GCP =====

GCE_REGION='asia-northeast1'
GCE_ZONE="${GCE_REGION}-c"

function _gcloud() {
  if which gcloud > /dev/null; then
    gcloud $@
  else
    echo command not found: gcloud
    echo "  -> gcloud $@"
  fi
}

## ===== GCE =====

function _gce() {
  _gcloud compute $@
}
alias gce=_gce

function _gce_instances() {
  _gce instances $@
}

function _gce_list() {
  _gce_instances list
}
alias gce_list=_gce_list

function gce_state() {
  local line=$(_gce_list | tail -n +2 | peco)
  local name=$(echo $line | awk '{print $1}')
  local zone=$(echo $line | awk '{print $2}')
  local cmd=$(echo "start\nstop\ndelete" | peco)
  [ $cmd = "" ] && return 0
  _gce_instances $cmd $name --zone $zone
}

function gce_create() {
  local image="$(_gce images list | grep -E READY --color=none | peco)"
  [ "$image" = "" ] && return 1
  local project=$(echo $image | awk '{print $2}')
  local family=$(echo $image | awk '{print $3}')

  local machine="$(_gce machine-types list --zones "$GCE_ZONE" | tail -n +2 | peco)"
  local disk="$(_gce disk-types list --zones "$GCE_ZONE" | tail -n +2 | peco)"

  machine=$(echo $machine | awk '{print $1}')
  disk=$(echo $disk | awk '{print $1}')
  [ "$machine" = "" ] || [ "$disk" = "" ] && return 1

  local name=$1
  if echo $name | grep "^-" > /dev/null; then
    name=`get_name`
  else
    if [ "$name" = "" ]; then
      name=`get_name`
    else
      shift
    fi
  fi
  {
    res=$(_gce_instances create $name \
      --image-family $family \
      --image-project $project \
      --zone $GCE_ZONE \
      --machine-type $machine \
      --boot-disk-size 30GB \
      --boot-disk-type $disk \
      $@)
    echo $res
    ip=`echo $res | tail -n 1 | sed -e "s#.* \([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*#\\1#"`
    [ ! "$ip" = "" ] && ssh-keygen -f "/home/kaneshin/.ssh/known_hosts" -R "$ip" 1> /dev/null 2> /dev/null
    user=$(git config --get github.user)
    cmd="'curl -L -s \"https://github.com/${user}.keys\" >> ~/.ssh/authorized_keys'"
    echo "gcloud compute ssh $name --zone $GCE_ZONE --command $cmd"
    echo "ansible-playbook -i \"$ip,\" --user=`whoami` --private-key=~/.ssh/id_rsa playbook.yml"
  } & pid=$!; jobs_await $pid; wait $pid 1> /dev/null 2> /dev/null
  return 0
}

# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set ft=sh:

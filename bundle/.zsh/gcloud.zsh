# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 29-Dec-2016.

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

GCE_INSTANCES_DEFAULT_DISK_TYPE="pd-ssd"
GCE_INSTANCES_DEFAULT_DISK_SIZE="30GB"

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
  local line="$(_gce_list | tail -n +2 | peco)"
  local name="$(echo $line | awk '{print $1}')"
  local zone="$(echo $line | awk '{print $2}')"
  local cmd="$(echo "start\nstop\ndelete\ndescribe" | peco)"
  [ -z "$cmd" ] && return 1

  _gce_instances $cmd $name --zone $zone
}

function gce_create() {
  local image="$(_gce images list --standard-images | tail -n +2 | peco)"
  local project="$(echo $image | awk '{print $2}')"
  local family="$(echo $image | awk '{print $3}')"
  [ -z "$project" ] || [ -z "$family" ] && return 1

  local machine="$(_gce machine-types list --zones "$GCE_ZONE" | tail -n +2 | peco)"
  machine=$(echo $machine | awk '{print $1}')
  [ -z "$machine" ] && return 1

  # local disk="$(_gce disk-types list --zones "$GCE_ZONE" | tail -n +2 | peco)"
  # disk=$(echo $disk | awk '{print $1}')
  local disk="$GCE_INSTANCES_DEFAULT_DISK_TYPE"
  [ -z "$disk" ] && return 1

  local name=$(get_name)
  if [ -n "$1" ] && ! echo "$1" | grep "^--" > /dev/null; then
    name="$1"
    shift
  fi
  {
    result=$(_gce_instances create $name \
      --zone $GCE_ZONE \
      --image-family $family \
      --image-project $project \
      --machine-type $machine \
      --boot-disk-size $GCE_INSTANCES_DEFAULT_DISK_SIZE \
      --boot-disk-type $disk \
      $@)
    echo $result
  } & pid=$!; jobs_await $pid; wait $pid 1> /dev/null 2> /dev/null

  ip=$(_gce_instances list $name | tail -n 1 | sed -e "s#.* \([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*#\\1#")
  [ -n "$ip" ] && ssh-keygen -f "$HOME/.ssh/known_hosts" -R "$ip" 1> /dev/null 2> /dev/null

  user=$(git config --get github.user)
  if [ -n "$user" ]; then
    cmd="'curl -s -L \"https://github.com/${user}.keys\" >> ~/.ssh/authorized_keys'"
    # XXX: It doesn't work
    # gcloud compute ssh $name --zone $GCE_ZONE --command $cmd
    echo gcloud compute ssh $name --zone $GCE_ZONE --command $cmd
  fi

  echo "ansible-playbook -i \"$ip,\" --user=`whoami` --private-key=~/.ssh/id_rsa playbook.yml"
  if [ -f "playbook.yml" ]; then
    ansible-playbook -i "$ip," --user=$(whoami) --private-key=~/.ssh/id_rsa playbook.yml
  fi
}

function gce_create_snapshot() {
  local snapshot="$(_gce snapshots list | tail -n +2 | peco)"
  local device="$(echo $snapshot | awk '{print $1}')"
  [ -z "$device" ] && return 1

  local machine="$(_gce machine-types list --zones "$GCE_ZONE" | tail -n +2 | peco)"
  machine=$(echo $machine | awk '{print $1}')
  [ -z "$machine" ] && return 1

  # local disk="$(_gce disk-types list --zones "$GCE_ZONE" | tail -n +2 | peco)"
  # disk=$(echo $disk | awk '{print $1}')
  local disk="$GCE_INSTANCES_DEFAULT_DISK_TYPE"
  [ -z "$disk" ] && return 1

  local name=$(get_name)
  if [ -n "$1" ] && ! echo "$1" | grep "^--" > /dev/null; then
    name="$1"
    shift
  fi
  {
    result=$(_gce_instances create $name \
      --zone $GCE_ZONE \
      --machine-type $machine \
      --boot-disk-device-name $device \
      --boot-disk-size $GCE_INSTANCES_DEFAULT_DISK_SIZE \
      --boot-disk-type $disk \
      $@)
    echo $result
  } & pid=$!; jobs_await $pid; wait $pid 1> /dev/null 2> /dev/null

  ip=$(_gce_instances list $name | tail -n 1 | sed -e "s#.* \([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*#\\1#")
  [ -n "$ip" ] && ssh-keygen -f "$HOME/.ssh/known_hosts" -R "$ip" 1> /dev/null 2> /dev/null
}

# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set ft=sh:

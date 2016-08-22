# Maintainer:  Shintaro Kaneko <kaneshin0120@gmail.com>
# Last Change: 11-Aug-2016.

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

# ===== GCE =====

GCE_REGION='asia-east1'
GCE_ZONE="${GCE_REGION}-c"

function _gce_instances() {
  gcloud compute instances $@
}

function _gce_cmd() {
  line=$(_gce_instances list | peco)
  name=$(echo $line | awk '{print $1}')
  zone=$(echo $line | awk '{print $2}')
  res=""
  while [ ! "$res" = "Y" ] && [ ! "$res" = "N" ]; do
    echo -n "Do you want to $1 $name [y/N]? "
    read res < /dev/tty
    if [ "$res" = "" ]; then
      res="N"
    fi
    res=`echo "$res" | tr '[a-z]' '[A-Z]'`
  done
  if [ "$res" = "Y" ]; then
    { _gce_instances $1 $name --zone $zone
    } # & pid=$!; jobs_await $pid; wait $pid 1> /dev/null 2> /dev/null
  fi
}

function gce_create() {
  local image="$(gcloud compute images list | grep -E READY --color=none | peco)"
  [ "$image" = "" ] && return 1
  project=$(echo $image | awk '{print $2};')
  family=$(echo $image | awk '{print $3};')
  local machine=$(gcloud compute machine-types list --zones "$GCE_ZONE" | awk 'NR!=1 {print $1};' | peco)
  [ "$machine" = "" ] && return 1
  local disk=$(gcloud compute disk-types list --zones "$GCE_ZONE" | awk 'NR!=1 {print $1};' | peco)
  [ "$disk" = "" ] && return 1

  name=$1
  [ "$name" = "" ] && name=`get_name`
  {
    res=$(_gce_instances create $name --image-family $family --image-project $project --zone $GCE_ZONE --machine-type $machine --boot-disk-size 30GB --boot-disk-type $disk)
    echo $res
    ip=`echo $res | tail -n 1 | sed -e "s#.* \([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\).*#\\1#"`
    [ ! "$ip" = "" ] && ssh-keygen -f "/home/kaneshin/.ssh/known_hosts" -R "$ip" 1> /dev/null 2> /dev/null
    user=$(git config --get github.user)
    cmd="curl -L -s \"https://github.com/${user}.keys\" >> ~/.ssh/authorized_keys"
    gcloud compute ssh $name --zone $GCE_ZONE --command "$cmd"
    echo "ansible-playbook -i \"$ip,\" --user=`whoami` --private-key=~/.ssh/id_rsa playbook.yml"
  } & pid=$!; jobs_await $pid; wait $pid 1> /dev/null 2> /dev/null
  return 0
}

function gce() {
  line=$(_gce_instances list | peco)
  name=$(echo $line | awk '{print $1}')
  zone=$(echo $line | awk '{print $2}')
  cmd=$(echo "start\nstop\ndelete" | peco)
  [ $cmd = "" ] && return 0
  echo gcloud compute instances $cmd $name --zone $zone
  {
    gcloud compute instances $cmd $name --zone $zone
  } # & pid=$!; jobs_await $pid; wait $pid 1> /dev/null 2> /dev/null
}

function gce_list() {
  _gce_instances list
}

function gce_ip() {
  line=$(_gce_instances list | grep -E RUNNING | peco)
  ip=$(echo $line | awk '{print $5}')
  echo $ip
}

function gce_stop() {
  _gce_cmd stop
}

function gce_delete() {
  _gce_cmd delete
}

# vim:set ts=8 sts=2 sw=2 tw=0:
# vim:set ft=sh:
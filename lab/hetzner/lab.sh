#!/usr/bin/env bash
# Kubernetes practice lab on Hetzner Cloud.
#
#   ./lab.sh up [3|5]   create the servers (3 = cp1,w1,w2; 5 adds cp2,cp3). Re-run to add more.
#   ./lab.sh status     list servers, their IPs and whether node prep has finished
#   ./lab.sh ssh NAME   ssh in as root (e.g. ./lab.sh ssh cp1)
#   ./lab.sh down       DELETE all lab servers (stops billing). Network, firewall and key are kept (free).
#   ./lab.sh down --all also delete the network, firewall and SSH key
#
# Settings (environment variables):
#   TYPES      server types to try, in order          (default: "cx23 cpx22")
#   LOCATIONS  locations to try, in order             (default: "nbg1 hel1 fsn1")
#   K8S_MINOR  Kubernetes minor version to install    (default: 1.36, one behind the latest, for the upgrade task)
#   MY_IP      address allowed to reach SSH and API   (default: detected via ifconfig.me)
#   SSH_PUB    public key to install                  (default: ~/.ssh/id_ed25519.pub)
set -euo pipefail

LAB=jobprep
TYPES=${TYPES:-"cx23 cpx22"}
LOCATIONS=${LOCATIONS:-"nbg1 hel1 fsn1"}
K8S_MINOR=${K8S_MINOR:-1.36}
SSH_PUB=${SSH_PUB:-$HOME/.ssh/id_ed25519.pub}
IMAGE=ubuntu-24.04
HERE=$(cd "$(dirname "$0")" && pwd)

die() { echo "error: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null || die "$1 not found. $2"; }

preflight() {
  need hcloud "Install it: brew install hcloud"
  [ -n "${HCLOUD_TOKEN:-}" ] || [ -n "$(hcloud context active 2>/dev/null)" ] \
    || die "no Hetzner API token. Create one in the Hetzner Console (your project > Security > API tokens, Read & Write), then run: hcloud context create $LAB"
}

exists() { hcloud "$1" describe "$2" >/dev/null 2>&1; }

ensure_shared() {
  if ! exists ssh-key "$LAB"; then
    [ -f "$SSH_PUB" ] || die "no public key at $SSH_PUB. Make one: ssh-keygen -t ed25519"
    hcloud ssh-key create --name "$LAB" --public-key-from-file "$SSH_PUB" >/dev/null
    echo "created ssh key"
  fi

  if ! exists network "$LAB"; then
    hcloud network create --name "$LAB" --ip-range 10.0.0.0/16 >/dev/null
    hcloud network add-subnet "$LAB" --network-zone eu-central --type cloud --ip-range 10.0.1.0/24 >/dev/null
    echo "created private network 10.0.1.0/24"
  fi

  if ! exists firewall "$LAB"; then
    local ip=${MY_IP:-$(curl -4 -fsS https://ifconfig.me)}
    [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "could not detect your IP; set MY_IP=x.x.x.x"
    local rules
    rules=$(mktemp)
    cat >"$rules" <<EOF
[
  {"direction":"in","protocol":"tcp","port":"22","source_ips":["$ip/32"],"description":"ssh from me"},
  {"direction":"in","protocol":"tcp","port":"6443","source_ips":["$ip/32"],"description":"kubectl from me"},
  {"direction":"in","protocol":"icmp","source_ips":["$ip/32"],"description":"ping from me"}
]
EOF
    hcloud firewall create --name "$LAB" --rules-file "$rules" >/dev/null
    rm -f "$rules"
    echo "created firewall: only $ip can reach ports 22 and 6443 (private network traffic is not filtered)"
  fi
}

names_for() {
  case "$1" in
    3) echo "cp1 w1 w2" ;;
    5) echo "cp1 cp2 cp3 w1 w2" ;;
    *) die "size must be 3 or 5" ;;
  esac
}

create_server() {
  local name=$1 userdata=$2 type loc
  for loc in ${STICKY_LOC:-} $LOCATIONS; do
    for type in $TYPES; do
      if hcloud server create --name "$name" --type "$type" --image "$IMAGE" --location "$loc" \
          --ssh-key "$LAB" --network "$LAB" --firewall "$LAB" \
          --user-data-from-file "$userdata" --label "lab=$LAB" >/dev/null 2>"$userdata.err"; then
        echo "created $name: $type in $loc"
        STICKY_LOC=$loc   # keep the rest of the cluster in the same place
        return 0
      fi
      echo "  $type in $loc: $(tail -1 "$userdata.err")"
    done
  done
  die "could not create $name with any of: $TYPES in $LOCATIONS"
}

cmd_up() {
  local size=${1:-3} userdata
  preflight
  ensure_shared
  userdata=$(mktemp)
  sed "s/__K8S_MINOR__/$K8S_MINOR/g" "$HERE/cloud-init.yaml" >"$userdata"
  STICKY_LOC=$(hcloud server list -l "lab=$LAB" -o noheader -o columns=location 2>/dev/null | head -1)
  for name in $(names_for "$size"); do
    if exists server "$name"; then echo "$name exists"; else create_server "$name" "$userdata"; fi
  done
  rm -f "$userdata" "$userdata.err"
  echo
  echo "Node prep (containerd, kubeadm $K8S_MINOR) takes 2-4 minutes. Check with: $0 status"
}

cmd_status() {
  preflight
  printf '%-5s %-7s %-6s %-16s %-11s %s\n' NAME TYPE WHERE PUBLIC PRIVATE PREPPED
  hcloud server list -l "lab=$LAB" -o noheader -o columns=name,type,location,ipv4 | sort |
  while read -r name type loc ip; do
    priv=$(hcloud server describe "$name" -o json |
      python3 -c 'import json,sys; n=json.load(sys.stdin).get("private_net") or [{}]; print(n[0].get("ip","-"))')
    ready=$(ssh -n -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new \
      "root@$ip" 'test -f /root/NODE_READY && echo yes || echo "not yet"' 2>/dev/null || echo "no ssh yet")
    printf '%-5s %-7s %-6s %-16s %-11s %s\n' "$name" "$type" "$loc" "$ip" "$priv" "$ready"
  done
}

cmd_ssh() {
  [ -n "${1:-}" ] || die "usage: $0 ssh NAME"
  preflight
  exec hcloud server ssh "$1"
}

cmd_down() {
  preflight
  local servers
  servers=$(hcloud server list -l "lab=$LAB" -o noheader -o columns=name)
  if [ -n "$servers" ]; then
    echo "Deleting: $(echo $servers)"
    # shellcheck disable=SC2086
    hcloud server delete $servers
  else
    echo "no lab servers"
  fi
  if [ "${1:-}" = "--all" ]; then
    for r in firewall network ssh-key; do
      exists "$r" "$LAB" && hcloud "$r" delete "$LAB" && echo "deleted $r"
    done
  fi
  hcloud server list -l "lab=$LAB" -o noheader | grep -q . && die "some servers are still there" || echo "Nothing is billing now."
}

case "${1:-}" in
  up) shift; cmd_up "$@" ;;
  status) cmd_status ;;
  ssh) shift; cmd_ssh "$@" ;;
  down) shift; cmd_down "$@" ;;
  *) sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac

#!/bin/bash

# Script to test the openSUSE infrastructure Salt code in a local container
# Copyright (C) 2017-2024 openSUSE contributors
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

help() {
    echo 'Run tests on your workstation.'
    echo 'Do NOT run this as root.'
    echo
    echo "Arguments:"
    echo '-h - Print this text.'
    echo
    echo '-c - Use the specified existing container instead of instantiating a new one.'
    echo '-k - Path to a public SSH key to use for authentication. If not specified, an insecure key will be used.'
    echo '-p - Preserve container after tests finished running.'
    echo '-s - Test full highstates. This takes a lot of time!'
    echo
}

print() {
    printf '==> %s\n' "$1"
}

pprint() {
    printf '==> %s %s ...\n' "$1" "$(gum style --foreground \#96cb5c "$2")"
}

fail() {
    echo "$1"
    exit 1
}

pfail() {
    printf '! %s\n' "$(gum style --foreground \#d11137 FAILED)"
    exit 1
}

[ "$(id -u)" = 0 ] && help && exit 1
[ "$1" = '--help' ] && help && exit

CONTAINER=''
CONTAINER_ARGS=()
SSH_ARGS=( '-t' '-oStrictHostKeyChecking=no' '-oUserKnownHostsFile=/dev/null' '-oLogLevel=ERROR' '-lchecker' )
PRESERVE=false
HIGHSTATE=false

while getopts h:c:k:p:s arg; do
    case "$arg" in
        h) help && exit ;;
        c) CONTAINER="${OPTARG}" ;;
        k) PUBKEY=${OPTARG} ;;
        p) CONTAINER_ARGS+=('--rm') ; PRESERVE=true ;;
        s) HIGHSTATE=true ;;
        *) help && exit 1 ;;
    esac
done

print 'Pre-flight check ...'
test -f encrypted_pillar_recipients || fail 'Please run this script from the salt.git repository root.'
command -v podman >/dev/null || fail 'Please install Podman first.'
command -v ssh >/dev/null || fail 'Please install the OpenSSH client first.'
command -v rsync >/dev/null || fail 'Please install rsync first.'
getent hosts ipv6-localhost >/dev/null || fail 'Please ensure ipv6-localhost maps to ::1 (default on openSUSE).'
if [ -z "$PUBKEY" ] || ! file -bL "$PUBKEY" | grep -q 'OpenSSH .* public key'
then
    fail 'Please provide a public OpenSSH key using -k.'
fi

set -Cu

if [ -z "$CONTAINER" ]
then
    print 'Pulling container ...'
    podman pull -q registry.opensuse.org/opensuse/infrastructure/containers/heroes-salt-development-systemd \
      || fail 'Failed to pull container'

    print 'Preparing ...'
    PORT=2222
    while [ -n "$(ss -Htlno state listening sport = $PORT)" ]
    do
      PORT=$((PORT+1))
    done
    echo "$PORT"

    print 'Starting ...'
    CONTAINER=$( \
      podman run -de SSH_KEY="$(cat "$PUBKEY")" --health-interval 10s --health-start-period 15s "${CONTAINER_ARGS[@]}" -p "[::1]:$PORT:22" -v .:/home/geeko/salt-workspace:ro \
      registry.opensuse.org/opensuse/infrastructure/containers/heroes-salt-development-systemd:latest \
    )
    timeout 90 podman wait --condition healthy "$CONTAINER" >/dev/null \
      || fail 'Failed to start container'
    podman logs "$CONTAINER"
else
    print "Preparing container $CONTAINER ..."
    set -e
    podman ps | grep -q "$CONTAINER" || podman start "$CONTAINER"
    timeout 60 podman wait --condition healthy "$CONTAINER" >/dev/null \
      || fail 'Failed to start container'
    PORT="$(podman inspect -f '{{(index (index .NetworkSettings.Ports "22/tcp") 0).HostPort}}' "$CONTAINER" || echo null)"
    if [ "$PORT" = 'null' ] || ! podman ps | grep -q "$CONTAINER"
    then
        fail 'Cannot work with the specified container.'
    fi
    podman exec "$CONTAINER" test -f /var/adm/firstboot-ok || fail 'Existing container was not set up correctly or does not use the expected image.'
    podman exec "$CONTAINER" sh -c "echo $(cat "$PUBKEY") >> /home/checker/.ssh/authorized_keys"
    set +e
fi

SSH_ARGS+=("-p$PORT")
SSH="ssh ${SSH_ARGS[*]}"
RSYNC_ARGS=('-l' '-r' '-e' "$SSH")
SSH="$SSH ipv6-localhost"

$SSH true || fail 'Container connection failed.'
$SSH sudo install -do checker /srv/salt-formulas /srv/salt-testbed || fail 'Failed to create directories.'

rsync "${RSYNC_ARGS[@]}" . ipv6-localhost:/srv/salt-testbed || fail 'Failed to transfer repository.'

$SSH sh <<-EOS || echo 'Test suite returned with errors.'
  $(typeset -f pprint)
  $(typeset -f pfail)
  pushd /srv/salt-testbed >/dev/null

  pprint 'Preparing test environment'
  sudo bin/prepare_test_env.sh -g -s || pfail
  sudo sed -i 's/download-prg.infra.opensuse.org/download.opensuse.org/' /etc/zypp/repos.d/*

  pprint Testing: validate
  bin/test_validate.sh || pfail

  pprint Testing: show_highstate
  sudo bin/test_show_highstate.sh || pfail

  if [ "$HIGHSTATE" = 'true' ]
  then
    pprint Testing: highstate
    sudo bin/test_highstate.sh
  fi

  popd >/dev/null
  pprint 'All tests' completed
EOS

if [ "$PRESERVE" = 'false' ]
then
  print 'Removing container ...'
  podman stop "$CONTAINER" >/dev/null || fail 'Failed to stop container.'
  podman rm "$CONTAINER" >/dev/null || fail 'Failed to remove container.'
fi

echo Bye.

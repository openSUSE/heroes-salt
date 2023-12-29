#!/bin/bash

# Validate that a highstate works for all roles
# Takes the role name as an argument

set -u
role="$1"

[[ $(whoami) == 'root' ]] || { echo 'Please run this script as root'; exit 1; }

# sysctl: cannot stat /proc/sys/net/core/netdev_max_backlog (and some other /proc files): No such file or directory
( cd /sbin/ ; ln -sf /usr/bin/true sysctl )

source bin/get_colors.sh

test/setup/master_minion

# pre-populate dhparams, generation eats CPU resources and entropy
cp test/fixtures/dhparams /etc/haproxy/dhparam

IDFILE="pillar/id/$HOSTNAME.sls"

out="$role.txt"
echo "START OF $role" > "$out"

echo_INFO "Testing role: $role"

printf 'roles:\n- %s' "$role" >> "$IDFILE"

if [ -x "test/setup/role/$role" ]
then
  echo "Preparing test environment for role $role ..." >> "$out"
  test/setup/role/$role
fi

salt --out=raw --out-file=/dev/null "$HOSTNAME" saltutil.refresh_pillar

salt-call --retcode-passthrough --state-output=full --output-diff state.apply test=True >> "$out"
rolestatus=$?
echo >> "$out"

if test $rolestatus = 0; then
    echo_PASSED
else
    echo_FAILED
fi
echo

echo "END OF $role" >> "$out"

mkdir system
cp /var/log/salt/minion system/minion_log.txt
cp /var/log/salt/master system/master_log.txt
journalctl --no-pager > system/journal.txt

echo 'Output and logs can be found in the job artifacts!'
exit $rolestatus

vim:expandtab

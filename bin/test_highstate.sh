#!/bin/bash

# Validate that a highstate works for all roles
# Takes the role name as an argument

set -u
role="$1"

[[ $(whoami) == 'root' ]] || { echo 'Please run this script as root'; exit 1; }

# sysctl: cannot stat /proc/sys/net/core/netdev_max_backlog (and some other /proc files): No such file or directory
( cd /sbin/ ; ln -sf /usr/bin/true sysctl )

echo 'features: {"x509_v2": true}' > /etc/salt/minion.d/features_x509_v2.conf

source bin/get_colors.sh

# pre-populate dhparams, generation eats CPU resources and entropy
cp test/fixtures/dhparams /etc/haproxy/dhparam

cp test/fixtures/minion* /etc/salt/pki/minion/
cp /etc/salt/pki/minion/minion.pub /etc/salt/pki/master/minions/$(hostname)

install -o salt -g salt -d -m 0750 /var/log/salt
chown -R salt: /var/cache/salt/master

tee >/etc/salt/master <<EOF
file_roots:
  base:
  - /srv/salt
  - /usr/share/salt-formulas/states
interface: 127.0.0.1
log_level: info
user: salt
EOF
systemctl start salt-master
tee >/etc/salt/minion <<EOF
master: 127.0.0.1
#log_level: info
EOF
systemctl start salt-minion
salt-call test.ping

# gateway, hypervisor.cluster and hypervisor.standalone roles: infrastructure-formula needs virt_cluster
echo 'virt_cluster: falkor-bare' >> /etc/salt/grains

echo "== /etc/salt/grains =="
cat "/etc/salt/grains"
echo "== /etc/salt/grains END =="

IDFILE="pillar/id/$(hostname).sls"

sed s/runner/$(hostname)/ test/pillar/clusters.yaml >> "$IDFILE"
cat test/pillar/{mirrorcache,suse_ha,conntrackd-asgard}.sls >> "$IDFILE"

echo "== $IDFILE =="
cat "$IDFILE"
echo "== $IDFILE END =="

IDFILE_BASE="$IDFILE.base.sls"

cp "$IDFILE" "$IDFILE_BASE"

salt $(hostname) saltutil.refresh_grains
salt $(hostname) saltutil.refresh_pillar
salt $(hostname) mine.update

printf '[mysqld]\nskip-grant-tables\n' > /etc/my.cnf.d/danger.cnf
systemctl start mariadb

out="$role.txt"
echo "START OF $role" > "$out"

echo_INFO "Testing role: $role"

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

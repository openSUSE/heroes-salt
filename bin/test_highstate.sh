#!/bin/bash

# Validate that a highstate works for all roles

# Parameters:
# $1 - role numbers (actually line numbers for get_roles.py output) to test. Expects a format for   sed -n "$1 p"   - for example '1,10' or '50,$'
# if $1 is empty, that means   sed -n " p"   which will test all roles.


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

succeeded_roles=""
failed_roles=""
nr=0

for role in $(bin/get_roles.py | sed -n "$1 p"); do
    nr=$((( $nr  + 1)))
    rolestatus=0
    sls_role="salt/role/${role/./\/}.sls"
    out="$role.txt"
    echo "START OF $role" > "$out"
    echo_INFO "Testing role $nr: $role"

    cp "$IDFILE_BASE" "$IDFILE"
    printf "roles:\n- $role" >> "$IDFILE"

    if [ -x "test/setup/role/$role" ]
    then
      echo "Preparing test environment for role $role ..." >> "$out"
      test/setup/role/$role
    fi

    salt --out=raw --out-file=/dev/null "$HOSTNAME" saltutil.refresh_pillar

    echo "Testing role $role ..." >> "$out"

    reset_role

    salt-call --retcode-passthrough --state-output=full --output-diff state.apply test=True >> "$out"
    rolestatus=$?
    echo >> "$out"

    if test $rolestatus = 0; then
        succeeded_roles="$succeeded_roles $role"
        echo_PASSED
    else
        failed_roles="$failed_roles $role"
        echo_FAILED
        # tail -n100 "$out"
        STATUS=1
    fi
    echo

    echo "END OF $role" >> "$out"
done

mkdir system
cp /var/log/salt/minion system/minion_log.txt
cp /var/log/salt/master system/master_log.txt
journalctl --no-pager > system/journal.txt

echo "succeeded roles ($(echo $succeeded_roles | wc -w)): $succeeded_roles"
echo
echo "failed roles ($(echo $failed_roles | wc -w)): $failed_roles"
echo
echo 'Output and logs can be found in the job artifacts!'
exit $STATUS

vim:expandtab

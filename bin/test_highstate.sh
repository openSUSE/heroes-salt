#!/bin/bash

# Validate that a highstate works for all roles

[[ $(whoami) == 'root' ]] || { echo 'Please run this script as root'; exit 1; }

# sysctl: cannot stat /proc/sys/net/core/netdev_max_backlog (and some other /proc files): No such file or directory
( cd /sbin/ ; ln -sf /usr/bin/true sysctl )

echo 'features: {"x509_v2": true}' > /etc/salt/minion.d/features_x509_v2.conf

source bin/get_colors.sh

# cronie for /usr/bin/crontab (needed by salt to read existing crontab), PyMySQL for the mysql module to load, postsrsd/postgrey to provide their sysconfig files, system-user-mail to avoid warnings about the mail group not existing while creating more users, python3-ldap for the ldap3 module to load
zypper in -y kmod cronie python3-PyMySQL postsrsd postgrey system-user-mail python3-ldap mariadb redis7

rm -v /etc/zypp/repos.d/*.repo


# === role-specific workarounds ===

# countdown, warning only
useradd countdown

# documentation, warning only
useradd relsync

# - jekyll_master, warning only
# - web_jekyll, warning only
useradd web_jekyll

# mail_reminder, warning only
useradd mail_reminder

# mailman3, error
groupadd mailman
useradd mailman
groupadd mailmanweb
useradd mailmanweb

# matrix, errors
groupadd synapse
useradd synapse

# - mirrorcache-backstage, warning only
# - mirrorcache-webui, warning only
useradd mirrorcache

# mirrors_static, warning only
useradd mirrors_static
# mirrors_static error:   salt.exceptions.CommandExecutionError: Specified cwd '/home/mirrors_static/git/mirrors_static' either not absolute or does not exist
mkdir -p /home/mirrors_static/git/mirrors_static/
# git.set_config needs (even in test mode) a fully valid git repo with at least one commit
(cd /home/mirrors_static/git/mirrors_static/ && git init && git config user.email 'user@example.com' && touch foo && git add foo && git commit -m 'add foo')
chown -R mirrors_static /home/mirrors_static/git/mirrors_static/

# nameserver.recursor, warning only
groupadd pdns

# nameserver.secondary, warning only
# groupadd pdns, see above
useradd pdns

# paste, error
useradd paste

# pgbouncer, warning only
groupadd pgbouncer

# postgresql, warning only
groupadd postgres

# saltmaster, error in git.cloned
useradd cloneboy
# saltmaster, error:   fatal: detected dubious ownership in repository at '/builds/infra/salt'
#mkdir -p /builds/infra/salt

# - static_master, warning only
# - web_static, warning only
useradd web_static

# tsp, error in git.cloned
useradd tsp

# wikisearch, warning only
groupadd elasticsearch
useradd elasticsearch

# mirrorcache packages not available
mkdir /etc/mirrorcache
touch /etc/mirrorcache/conf.{env,ini}

# dummy OpenVPN user
mkdir -p /etc/openvpn/ccd-tcp
echo '1204::100' > /etc/openvpn/ccd-tcp/foo
pushd $PWD/salt/profile/vpn/openvpn/files/
ln -s odin $(hostname)
popd

# === END role-specific workarounds ===

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


sed -i -e '/virtual/d' -e '/virt_cluster/ s/:.*/: test/' /etc/salt/grains
echo "== /etc/salt/grains =="
cat "/etc/salt/grains"
echo "== /etc/salt/grains END =="

IDFILE="pillar/id/$(hostname).sls"

echo "  virt_cluster: test" >> "$IDFILE"
sed s/runner/$(hostname)/ test/pillar/clusters.yaml >> "$IDFILE"
cat test/pillar/mirrorcache.sls >> "$IDFILE"

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

reset_role() {
    cp "$IDFILE_BASE" "$IDFILE"
    printf "roles:\n- $role" >> "$IDFILE"
    salt --out=raw --out-file=/dev/null $(hostname) saltutil.refresh_pillar
}

succeeded_roles=""
failed_roles=""
nr=0

for role in $(bin/get_roles.py); do
    nr=$((( $nr  + 1)))
    rolestatus=0
    sls_role="salt/role/${role/./\/}.sls"
    out="$role.txt"
    echo "START OF $role" > "$out"

    echo_INFO "Testing role $nr: $role"
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

cp /var/log/salt/minion minion_log.txt
cp /var/log/salt/master master_log.txt

echo "succeeded roles ($(echo $succeeded_roles | wc -w)): $succeeded_roles"
echo
echo "failed roles ($(echo $failed_roles | wc -w)): $failed_roles"
exit $STATUS

vim:expandtab

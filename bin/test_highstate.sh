#!/bin/bash

# Validate that a highstate works for all roles

[[ $(whoami) == 'root' ]] || { echo 'Please run this script as root'; exit 1; }

# systemctl refuses to work in a container, but is needed by service.running. Replace it with /usr/bin/true to avoid useless error messages
# -> now using   salt-call --module-executors='[direct_call]'   instead of this workaround
# ( cd /usr/bin/ ; ln -sf true systemctl )

# sysctl: cannot stat /proc/sys/net/core/netdev_max_backlog (and some other /proc files): No such file or directory
( cd /sbin/ ; ln -sf /usr/bin/true sysctl )

# timedatectl failed: System has not been booted with systemd as init system (PID 1). Can't operate.
# output needed
( cd /usr/bin/ ; ( echo '#!/bin/sh' ; echo 'echo "               Local time: Sun 2023-11-19 16:43:25 UTC
           Universal time: Sun 2023-11-19 16:43:25 UTC
                 RTC time: Sun 2023-11-19 16:43:24
                Time zone: UTC (UTC, +0000)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no"' ) > timedatectl ; chmod +x timedatectl)

echo 'features: {"x509_v2": true}' > /etc/salt/minion.d/features_x509_v2.conf


source bin/get_colors.sh

# cronie for /usr/bin/crontab (needed by salt to read existing crontab)
zypper in -y kmod cronie

zypper in salt-master

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
(cd /home/mirrors_static/git/mirrors_static/ && git init)

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
mkdir -p /builds/infra/salt

# - static_master, warning only
# - web_static, warning only
useradd web_static

# tsp, error in git.cloned
useradd tsp

# wikisearch, warning only
groupadd elasticsearch
useradd elasticsearch

# === END role-specific workarounds ===


sed -i -e '/virtual/d' -e '/virt_cluster/ s/:.*/: test/' /etc/salt/grains
echo "== /etc/salt/grains =="
cat "/etc/salt/grains"
echo "== /etc/salt/grains END =="


IDFILE="pillar/id/$(hostname).sls"

echo "  virt_cluster: test" >> "$IDFILE"
echo "== $IDFILE =="
cat "$IDFILE"
echo "== $IDFILE END =="

IDFILE_BASE="$IDFILE.base.sls"

cp "$IDFILE" "$IDFILE_BASE"

reset_role() {
    cp "$IDFILE_BASE" "$IDFILE"
    printf "roles:\n- $role" >> "$IDFILE"
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

    # --module-executors='[direct_call]' should solve "Cannot run in offline mode. Failed to get information on unit", see https://www.reddit.com/r/saltstack/comments/vu8d5t/systemd_offline/ - but in practise it doesn't
    salt-call --local --module-executors='[direct_call]' state.highstate --retcode-passthrough --state-output=full --output-diff test=True >> "$out"
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

echo "succeeded roles ($(echo $succeeded_roles | wc -w)): $succeeded_roles"
echo
echo "failed roles ($(echo $failed_roles | wc -w)): $failed_roles"
exit $STATUS

vim:expandtab

apparmor:
  local:
    sbin.syslog-ng:
      - /etc/syslog-ng/conf.d/server.d/{,*} r

sudo:
  groups:
    logger-admins:
      - '{{ grains['host'] }} = (root) NOPASSWD:SETENV: /usr/sbin/tcpdump -s0 -Unw - -i os-log port 601'

# syslog-ng configuration happens in static files under salt/profile/log/syslog-ng/files/

zypper:
  packages:
    lnav: {}

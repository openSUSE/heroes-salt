apparmor:
  local:
    sbin.syslog-ng:
      - /etc/syslog-ng/conf.d/server.d/{,*} r

# syslog-ng configuration happens in static files under salt/profile/log/syslog-ng/files/

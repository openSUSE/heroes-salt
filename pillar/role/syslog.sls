rsyslog:
  custom:
    - salt://profile/log/files/etc/rsyslog.d/server.conf
  listentcp: true
  target: false

zypper:
  packages:
    lnav: {}

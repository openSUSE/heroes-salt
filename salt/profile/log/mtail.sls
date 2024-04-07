include:
  - mtail
  - rsyslog

/var/log/syslog:
  file.mknod:
    - ntype: p
    - mode: '0640'
    - watch_in:
        - service: mtail
        - service: rsyslog

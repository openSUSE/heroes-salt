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
  acl.present:
    - acl_type: user
    - acl_name: mtail
    - perms: r
    - require:
        - file: /var/log/syslog

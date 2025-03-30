include:
  - mtail
  - .syslog-ng

/var/log/syslog:
  file.mknod:
    - ntype: p
    - mode: '0640'
    - watch_in:
        - service: mtail
        - service: syslog-ng_service
  acl.present:
    - acl_type: user
    - acl_name: mtail
    - perms: r
    - require:
        - file: /var/log/syslog

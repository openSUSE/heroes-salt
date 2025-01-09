rsyslog_package:
  pkg.removed:
    - name: rsyslog

rsyslog_files:
  file.absent:
    - names:
        - /etc/rsyslog.conf.rpmsave
        - /etc/rsyslog.d
    - require:
        - pkg: rsyslog_package

syslog-ng_package:
  pkg.installed:
    - name: syslog-ng
    - require:
        - pkg: rsyslog_package

syslog-ng_service:
  service.running:
    - name: syslog-ng
    - enable: true
    - reload: true
    - require:
        - pkg: syslog-ng_package

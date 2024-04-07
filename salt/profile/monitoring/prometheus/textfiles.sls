/var/spool/prometheus:
  file.directory

/usr/local/libexec/systemd:
  file.directory:
    - mode: '0750'

textfile_files:
  file.managed:
    - names:
        - /usr/local/libexec/systemd/zypper-metrics.sh:
            - source: salt://{{ slspath }}/files/textfile/scripts/zypper-metrics.sh.jinja
            - mode: '0750'
        - /etc/systemd/system/zypper-metrics.service:
            - source: salt://{{ slspath }}/files/textfile/systemd/zypper-metrics.service.jinja
        - /etc/systemd/system/zypper-metrics.timer:
            - source: salt://{{ slspath }}/files/textfile/systemd/zypper-metrics.timer.jinja
    - template: jinja

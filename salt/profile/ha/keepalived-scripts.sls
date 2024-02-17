/usr/local/sbin/check_keepalived_scripts:
  file.managed:
    - source: salt://profile/ha/files/check_keepalived_scripts.sh.jinja
    - template: jinja
    - mode: '0755'

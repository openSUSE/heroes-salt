/usr/local/sbin/check_keepalived_scripts:
  file.managed:
    - source: salt://profile/ha/files/check_keepalived_scripts.sh.jinja
    - template: jinja
    - mode: '0755'

/usr/local/sbin/shut_vrrp:
  file.managed:
    - source: salt://profile/ha/files/shut_vrrp.sh.jinja
    - template: jinja
    - mode: '0755'

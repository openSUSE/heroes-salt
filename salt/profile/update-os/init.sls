/usr/local/sbin/update-os:
  file.managed:
    - source: salt://{{ slspath }}/files/update-os.sh.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: '0744'

/etc/mirrorcache:
  file.directory:
    - user:  mirrorcache
    - group: root
    - mode:  740

mirrorcache.conf.env:
  file.managed:
    - name: /etc/mirrorcache/conf.env
    - source: salt://profile/mirrorcache/files/etc/mirrorcache/conf.env
    - template: jinja
    - backup: minion


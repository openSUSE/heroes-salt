include:
  - salt.master

remove-etc-salt-master:
  file.managed:
    - name: /etc/salt/master
    - template: jinja
    - source: salt://profile/salt/files/master_minion_default_config
    - defaults:
        salt_service: master
    - listen_in:
        - service: salt-master

/etc/salt/gpgkeys:
  file.directory:
    - user: salt
    - group: salt
    - dir_mode: 700
    - file_mode: 600
    - recurse:
        - user
        - group
        - mode

/srv/reactor:
  file.recurse:
    - source: salt://profile/salt/files/srv/reactor
    - template: jinja

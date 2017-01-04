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

/srv/reactor:
  file.recurse:
    - source: salt://profile/salt/files/reactor

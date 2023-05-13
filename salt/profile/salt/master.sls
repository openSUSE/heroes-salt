include:
  - salt.gitfs.pygit2
  - salt.master
  - .git

remove-etc-salt-master:
  file.managed:
    - name: /etc/salt/master
    - template: jinja
    - source: salt://profile/salt/files/etc/salt/master_minion_default_config
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

/usr/local/sbin/saltmaster-deploy:
  file.managed:
    - source: salt://profile/salt/files/usr/local/sbin/saltmaster-deploy
    - template: jinja
    - mode: 700

/srv/reactor:
  file.recurse:
    - source: salt://profile/salt/files/srv/reactor
    - template: jinja

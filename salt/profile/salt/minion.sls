include:
  - salt.minion

remove-etc-salt-minion:
  file.managed:
    - name: /etc/salt/minion
    - template: jinja
    - source: salt://profile/files/master_minion_default_config
    - defaults:
        salt_service: minion
    - listen_in:
        - service: salt-minion

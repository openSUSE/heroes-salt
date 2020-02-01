{% set roles = salt['grains.get']('roles', []) %}

synapse_conf_dir:
  file.directory:
    - name: /etc/matrix-synapse/

synapse_appservices_dir:
  file.directory:
    - name: /etc/matrix-synapse/appservices

synapse_conf_file:
  file.managed:
    - name: /etc/matrix-synapse/homeserver.yaml
    - source: salt://profile/matrix/files/homeserver.yaml
    - template: jinja
    - require:
      - file: synapse_conf_dir
    - require_in:
      - service: synapse_service
    - watch_in:
      - module: synapse_restart

discord_conf_file:
  file.managed:
    - name: /var/lib/matrix-synapse/discord/config.yaml
    - source: salt://profile/matrix/files/config-discord.yaml
    - template: jinja
    - require:
      - file: synapse_conf_dir
    - require_in:
      - service: synapse_service
    - watch_in:
      - module: synapse_restart

synapse_appservice_discord_file:
  file.managed:
    - name: /etc/matrix-synapse/appservices/appservice-discord.yaml
    - source: salt://profile/matrix/files/appservice-discord.yaml
    - require:
      - file: /var/lib/matrix-synapse/discord
    - watch_in:
      - module: discord_restart

synapse_log_conf_file:
  file.managed:
    - name: /etc/matrix-synapse/log.yaml
    - source: salt://profile/matrix/files/log_config
    - require:
      - file: synapse_conf_dir
    - require_in:
      - service: synapse_service
    - watch_in:
      - module: synapse_restart

/etc/matrix-synapse/signing.key:
  file.managed:
    - contents_pillar: profile:matrix:signing_key
    - mode: 600
    - user: synapse

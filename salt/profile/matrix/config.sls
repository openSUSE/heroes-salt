riot_dependencies:
  pkg.installed:
    - pkgs:
      - riot-web

riot_conf_dir:
  file.directory:
    - name: /etc/riot-web/

riot_conf_file:
  file.managed:
    - name: /etc/riot-web/config.json
    - source: salt://profile/matrix/files/config-riot.json
    - require:
      - file: riot_conf_dir

synapse_conf_dir:
  file.directory:
    - name: /etc/matrix-synapse/

/data/matrix:
  file.directory:
    - user: synapse
    - group: synapse

/data/matrix/media_store:
  file.directory:
    - user: synapse
    - group: synapse

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

/etc/matrix-synapse/signing.key:
  file.managed:
    - contents_pillar: profile:matrix:signing_key
    - mode: 640
    - user: root
    - group: synapse

/etc/matrix-synapse/irc_password.pem:
  file.managed:
    - contents_pillar: profile:matrix:appservices:irc:pass_enc_key
    - mode: 640
    - user: root
    - group: synapse

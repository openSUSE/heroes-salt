heisenbridge_pkgs:
  pkg.installed:
    - pkgs:
      - heisenbridge

heisenbridge_conf_file:
  suse_sysconfig.sysconfig:
    - name: /etc/sysconfig/heisenbridge
    - key_values:
        HEISENBRIDGE_LISTEN_ADDRESS: 127.0.0.1
        HEISENBRIDGE_LISTEN_PORT: 9898
        HEISENBRIDGE_HOMESERVER_URL: http://127.0.0.1:8008
        HEISENBRIDGE_EXTRA_OPTIONS: >-
          --owner @hellcp:opensuse.org
    - require:
      - pkg: heisenbridge_pkgs

heisenbridge_appservice_file:
  file.managed:
    - name: /etc/heisenbridge/registration.yaml
    - source: salt://profile/matrix/files/appservice-heisenbridge.yaml
    - user: synapse
    - template: jinja
    - require:
      - pkg: heisenbridge_pkgs

synapse_appservice_heisenbridge_file:
  file.managed:
    - name: /etc/matrix-synapse/appservices/appservice-heisenbridge.yaml
    - source: salt://profile/matrix/files/appservice-heisenbridge.yaml
    - user: synapse
    - template: jinja
    - require:
      - pkg: heisenbridge_pkgs

heisenbridge_service:
  service.running:
    - name: heisenbridge
    - enable: True
    - require:
      - pkg: heisenbridge_pkgs
      - service: synapse_service
    - watch:
      - suse_sysconfig: heisenbridge_conf_file
      - file: heisenbridge_appservice_file
      - file: synapse_appservice_heisenbridge_file

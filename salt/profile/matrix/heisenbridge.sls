heisenbridge_pkgs:
  pkg.installed:
    - pkgs:
      - heisenbridge

heisenbridge_conf_file:
  file.managed:
    - name: /etc/sysconfig/heisenbridge
    - source: salt://profile/matrix/files/config-heisenbridge
    - template: jinja
    - user: synapse
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
  file.symlink:
    - name: /etc/matrix-synapse/appservices/appservice-heisenbridge.yaml
    - target: /etc/heisenbridge/registration.yaml

heisenbridge_service:
  service.running:
    - name: heisenbridge
    - enable: True
    - require:
      - pkg: heisenbridge_pkgs
      - service: synapse_service
    - watch:
      - file: heisenbridge_conf_file
      - file: heisenbridge_appservice_file
      - file: synapse_appservice_heisenbridge_file

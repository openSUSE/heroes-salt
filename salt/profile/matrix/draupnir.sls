draupnir_package:
  pkg.installed:
    - pkg: draupnir

draupnir_config:
  file.managed:
    - name: /etc/draupnir/default.yaml
    - source: salt://profile/matrix/files/draupnir.yaml
    - template: jinja
    - require:
        - pkg: draupnir_package

draupnir_token:
  file.managed:
    - name: /etc/draupnir/token
    - contents_pillar: profile:matrix:draupnir:token
    - contents_newline: false
    - require:
        - pkg: draupnir_package

draupnir_service:
  service.running:
    - name: draupnir
    - enable: true
    - require:
        - pkg: draupnir_package
        - file: draupnir_config
        - file: draupnir_token

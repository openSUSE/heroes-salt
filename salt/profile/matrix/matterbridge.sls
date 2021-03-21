matterbridge_dependencies:
  pkg.installed:
    - pkgs:
      - matterbridge

matterbridge_conf:
  file.managed:
    - name: /etc/matterbridge/matterbridge.toml
    - source: salt://profile/matrix/files/matterbridge.toml
    - template: jinja
    - group: matterbridge
    - require_in:
      - service: matterbridge_service

matterbridge_service:
  service.running:
    - name: matterbridge
    - enable: True

matterbridge_restart:
  module.wait:
    - name: service.restart
    - m_name: matterbridge
    - require:
      - service: matterbridge_service

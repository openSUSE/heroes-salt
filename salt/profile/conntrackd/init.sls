{%- set config = '/etc/conntrackd/conntrackd.conf' %}
profile_conntrackd_config:
  file.managed:
    - name: {{ config }}
    - source: salt://profile/conntrackd/files{{ config }}.jinja
    - template: jinja

profile_conntrackd_service:
  service.running:
    - name: conntrackd
    - enable: true
    - watch:
      - file: profile_conntrackd_config

include:
  - profile.log.syslog-ng

{%- set directory_base = '/etc/syslog-ng/conf.d/' %}

syslog-ng_client_configuration:
  file.managed:
    - name: {{ directory_base }}client.conf
    - source: salt://profile/log/syslog-ng/files{{ directory_base }}client.conf
    - template: jinja
    - require:
        - pkg: syslog-ng_package
    - watch_in:
        - service: syslog-ng_service

include:
  - profile.log.syslog-ng

{%- set directory_base = '/etc/syslog-ng/conf.d/' %}
{%- set directory_server = directory_base ~ 'server.d/' %}

syslog-ng_server_directory:
  file.directory:
    - name: {{ directory_server }}
    - require:
        - pkg: syslog-ng_package

syslog-ng_server_configuration:
  file.managed:
    - name: {{ directory_base }}server.conf
    - source: salt://profile/log/syslog-ng/files{{ directory_base }}server.conf
    - template: jinja
    - require:
        - pkg: syslog-ng_package
    - watch_in:
        - service: syslog-ng_service

syslog-ng_server_configuration_tree:
  file.recurse:
    - name: {{ directory_server }}
    - source: salt://profile/log/syslog-ng/files{{ directory_server }}
    - clean: true
    - template: jinja
    - require:
        - pkg: syslog-ng_package
        - file: syslog-ng_server_directory
    - watch_in:
        - service: syslog-ng_service

syslog-ng_server_logrotate_configuration:
  file.managed:
    - name: /etc/logrotate.d/remote
    - source: salt://profile/log/syslog-ng/files/etc/logrotate.d/remote.jinja
    - mode: '0644'
    - template: jinja

{% set appservices = salt['pillar.get']('profile:matrix:appservices') %}

appservice_pgks:
  pkg.installed:
    - pkgs:
      - git
      - nodejs10
      - npm10
      - nodejs-common
      - make
      - gcc
      - gcc-c++

{% for dir, data in appservices.items() %}
/var/lib/matrix-synapse/{{ dir }}:
  file.directory:
    - user: synapse

{{ data.get('repo') }}:
  git.latest:
    - branch: {{ data.get('branch', 'master') }}
    - target: /var/lib/matrix-synapse/{{ dir }}
    - rev: {{ data.get('branch', 'master') }}
    - user: synapse


{{ dir }}_conf_file:
  file.managed:
    - name: /var/lib/matrix-synapse/{{ dir }}/config.yaml
    - source: salt://profile/matrix/files/config-{{ dir }}.yaml
    - template: jinja
    - user: synapse
    - require:
      - file: /var/lib/matrix-synapse/{{ dir }}
    - require_in:
      - service: {{ dir }}_service
    - watch_in:
      - module: {{ dir }}_restart

{{ dir }}_appservice_file:
  file.managed:
    - name: /var/lib/matrix-synapse/{{ dir }}/{{ dir }}-registration.yaml
    - source: salt://profile/matrix/files/appservice-{{ dir }}.yaml
    - user: synapse
    - template: jinja
    - require:
      - file: /var/lib/matrix-synapse/{{ dir }}
    - watch_in:
      - module: {{ dir }}_restart

synapse_appservice_{{ dir }}_file:
  file.managed:
    - name: /etc/matrix-synapse/appservices/appservice-{{ dir }}.yaml
    - source: salt://profile/matrix/files/appservice-{{ dir }}.yaml
    - template: jinja
    - require:
      - file: /var/lib/matrix-synapse/{{ dir }}
    - watch_in:
      - module: {{ dir }}_restart

{{ dir }}_boostrap:
  cmd.run:
    - name: npm install
    - cwd: /var/lib/matrix-synapse/{{ dir }}
    - runas: synapse
    - env:
      - NODE_VERSION: 10

{% if data.get('build') == True %}
{{ dir }}_build:
  cmd.run:
    - name: npm run build
    - cwd: /var/lib/matrix-synapse/{{ dir }}
    - runas: synapse
    - env:
      - NODE_VERSION: 10
{% endif %}

{{ dir }}_systemd_file:
  file.managed:
    - name: /etc/systemd/system/{{ dir }}.service
    - template: jinja
    - context:
      dir: {{ dir }}
      port: {{ data.get('port') }}
    - source: salt://profile/matrix/files/appservice.service
    - require_in:
      - service: {{ dir }}_service

{{ dir }}_service:
  service.running:
    - name: {{ dir }}
    - enable: True
    - require:
      - service: synapse_service

{{ dir }}_restart:
  module.wait:
    - name: service.restart
    - m_name: {{ dir }}
    - require:
      - service: synapse_service
      - service: {{ dir }}_service
{% endfor %}

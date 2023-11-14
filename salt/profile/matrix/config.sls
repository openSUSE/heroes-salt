include:
  - .nginx

element_dependencies:
  pkg.installed:
    - pkgs:
      - element-web

element_conf_dir:
  file.directory:
    - name: /etc/riot-web/

element_conf_file:
  file.managed:
    - name: /etc/riot-web/config.json
    - source: salt://profile/matrix/files/config-element.json
    - require:
      - file: element_conf_dir

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

workers_conf_dir:
  file.directory:
    - name: /etc/matrix-synapse/workers/
    - require_in:
      - file: workers_nginx_file
      - file: upstreams_nginx_file

{% set workers = salt['pillar.get']('profile:matrix:workers') %}

{% for app, types in workers.items() %}
{% for type in types %}
{% for worker, port in type.get('workers').items() %}
/etc/matrix-synapse/workers/{{worker}}.yaml:
  file.managed:
    - source: salt://profile/matrix/files/worker.yaml
    - template: jinja
    - context:
        worker: {{ worker }}
        port: {{ port }}
        app: {{ app }}
        resources: {{ type.get('resources') }}
        config: {{ type.get('config') }}
    - require:
      - file: workers_conf_dir
    - require_in:
      - service: {{worker}}_service
    - watch_in:
      - module: {{worker}}_restart

{% endfor %}
{% endfor %}
{% endfor %}

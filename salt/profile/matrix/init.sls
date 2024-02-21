include:
  - .directories
  - .nginx

synapse_service:
  service.running:
    - name: matrix-synapse.target
    - enable: True

{%- set workers = salt['pillar.get']('profile:matrix:workers') %}

{%- for app, types in workers.items() %}
{%- for type in types %}
{%- for worker, port in type.get('workers').items() %}

{{ worker }}_service:
  service.running:
    - name: matrix-synapse-worker@{{ worker }}.service
    - enable: True
    - require:
      - file: synapse_worker_systemd_file

{%- endfor %}
{%- endfor %}
{%- endfor %}

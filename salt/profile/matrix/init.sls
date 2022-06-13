synapse_service:
  service.running:
    - name: matrix-synapse.target
    - enable: True

synapse_restart:
  module.wait:
    - name: service.restart
    - m_name: matrix-synapse.target
    - require:
      - service: synapse_service

{% set workers = salt['pillar.get']('profile:matrix:workers') %}

{% for app, types in workers.items() %}
{% for type in types %}
{% for worker, port in type.get('workers').items() %}

{{worker}}_service:
  service.running:
    - name: matrix-synapse-worker@{{worker}}.service
    - enable: True
    - require:
      - file: synapse_worker_systemd_file

{{worker}}_restart:
  module.wait:
    - name: service.restart
    - m_name: matrix-synapse-worker@{{worker}}.service
    - require:
      - service: {{worker}}_service

{% endfor %}
{% endfor %}
{% endfor %}

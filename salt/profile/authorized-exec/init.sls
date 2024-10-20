{%- set mypillar = salt['pillar.get']('profile:authorized-exec', {}) %}
{%- set directory = '/etc/authorized-exec' %}

{%- if mypillar %}

authorized-exec_package:
  pkg.installed:
    - name: authorized-exec

authorized-exec_directory:
  file.directory:
    - name: {{ directory }}
    {#- directory permissions are managed by RPM #}
    - clean: true
    - require:
        - file: authorized-exec_configs

authorized-exec_configs:
  file.managed:
    - names:
        {%- for config, content in mypillar.items() %}
        - {{ directory }}/{{ config }}:
            - context:
                config: {{ content }}
        {%- endfor %}
    - source: salt://profile/authorized-exec/files/authorized-exec.jinja
    - check_cmd: perl -c
    - mode: '0644'
    - template: jinja

{%- else %}

authorized-exec_package:
  pkg.removed:
    - name: authorized-exec

authorized-exec_configs:
  file.absent:
    - name: {{ directory }}

{%- endif %}

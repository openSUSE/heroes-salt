pgbouncer_packages:
  pkg.installed:
    - name: pgbouncer

{#- TODO: pillar managed config
{%- set mypillar = salt['pillar.get']('profile:pgbouncer', {}) %}
{%- set myconfig = mypillar.get('config', {}) %}
{%- if myconfig %}
pgbouncer_config:
  ini_manage.options_present:
    - seperator: '='
    - strict: True
    - sections:
        {%- for section, options in myconfig.items() %}
        {{ section }}:
          {%- for key, value in options.items() %}
          '{{ key }}': '{{ value }}'
          {%- endfor %}
        {%- endfor %}
{%- endif %}
#}

{%- set host = grains['host'] %}
{%- if host.startswith('runner-') %}
{%- set cluster = 'hel' %} {#- use an arbitrary cluster for the CI test #}
{%- else %}
{%- set cluster = grains['host'][:-1] %}
{%- endif %}

{%- set source = 'salt://profile/pgbouncer/files/' ~ cluster %}

pgbouncer_config:
  file.managed:
    - names:
      - /etc/pgbouncer/pgbouncer.ini:
        - source: {{ source }}/etc/pgbouncer/pgbouncer.ini
      - /etc/pgbouncer/pg_hba.conf:
        - source: {{ source }}/etc/pgbouncer/pg_hba.conf
      - /etc/pgbouncer/userlist.txt:
        - source: {{ source }}/etc/pgbouncer/userlist.txt.jinja
        - template: jinja
    - user: root
    - group: pgbouncer
    - mode: '0640'
    - require:
      - pkg: pgbouncer_packages

pgbouncer_service:
  service.running:
    - name: pgbouncer
    - enable: True
    - reload: True
    - require:
      - pkg: pgbouncer_packages
    - watch:
      - file: pgbouncer_config

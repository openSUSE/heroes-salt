{%- set id = salt['grains.get']('id') -%}
{%- set id_subst = id.replace('.', '_') -%}
{%- set pillar_id = '/srv/pillar/id/' ~ id_subst ~ '.sls' %}
{%- set idstruct = salt['slsutil.renderer'](pillar_id) %}
{%- set cluster = idstruct.get('cluster') %}
{%- set roles = idstruct.get('roles', []) %}
{%- set osfullname = salt['grains.get']('osfullname') -%}

{{ saltenv }}:
  {%- if id[-7:] != '_master' %}
  '*':
    - common
  'osfullname:{{ osfullname }}':
    - match: grain
    - osfullname.{{ osfullname.replace(' ', '_') }}
  {%- endif %}
  '{{ id }}':
    - id.{{ id_subst }}
  {%- if cluster %}
    - cluster.{{ cluster }}
  {%- endif %}
  {%- for role in roles %}
    - role.{{ role }}
  {%- endfor %}

{%- set id = salt['grains.get']('id') -%}
{%- set id_subst = id.replace('.', '_') -%}
{%- set pillar_id = '/srv/pillar/id/' ~ id_subst ~ '.sls' %}
{%- set idstruct = salt['slsutil.renderer'](pillar_id) %}
{%- set roles = idstruct.get('roles', []) %}
{%- set osfullname = salt['grains.get']('osfullname') -%}
{%- set virt_cluster = salt['grains.get']('virt_cluster') -%}

{{ saltenv }}:
  '*':
    - common
  'osfullname:{{ osfullname }}':
    - match: grain
    - osfullname.{{ osfullname.replace(' ', '_') }}
  '{{ id }}':
    - id.{{ id_subst }}
  {%- for role in roles %}
    - role.{{ role }}
  {%- endfor %}


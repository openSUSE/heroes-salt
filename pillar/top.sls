{%- set id = salt['grains.get']('id') -%}
{%- set id_subst = id.replace('.', '_') -%}
{%- set pillar_id = '/srv/pillar/id/' ~ id_subst ~ '.sls' %}
{%- set idstruct = salt['slsutil.renderer'](pillar_id) %}
{%- set roles = idstruct.get('roles', []) %}
{%- set osfullname = salt['grains.get']('osfullname') -%}
{%- set salt_cluster = salt['grains.get']('salt_cluster') -%}
{%- set virt_cluster = salt['grains.get']('virt_cluster') -%}

{{ saltenv }}:
  '*':
    - common
  'osfullname:{{ osfullname }}':
    - match: grain
    - osfullname.{{ osfullname.replace(' ', '_') }}
  {% if salt_cluster in ['opensuse', 'geeko'] %}
  'salt_cluster:{{ salt_cluster }}':
    - match: grain
    - salt_cluster.{{ salt_cluster }}
    - salt_cluster.{{ salt_cluster }}.osfullname.{{ osfullname.replace(' ', '_') }}
  {% endif %}
  '{{ id }}':
    - id.{{ id_subst }}
  {%- for role in roles %}
    - role.{{ role }}
  {%- endfor %}


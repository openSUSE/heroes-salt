{% set id = salt['grains.get']('id') %}
{% set osfullname = salt['grains.get']('osfullname') %}
{% set osmajorrelease = salt['grains.get']('osmajorrelease') %}
{% set roles = salt['grains.get']('roles', []) %}
{% set salt_cluster = salt['grains.get']('salt_cluster') %}
{% set virtual = salt['grains.get']('virtual') %}

{{ saltenv }}:
  '*':
    - common
  {% for role in roles %}
  'roles:{{ role }}':
    - match: grain
    - ignore_missing: True
    - role.{{ role }}
  {% endfor %}
  'virtual:{{ virtual }}':
    - match: grain
    - virtual.{{ virtual }}
  'osfullname:{{ osfullname }}':
    - match: grain
    - osfullname.{{ osfullname.replace(' ', '_') }}
  'osmajorrelease:{{ osmajorrelease }}':
    - match: grain
    - osmajorrelease.{{ osmajorrelease }}
  {% if salt_cluster in ['opensuse', 'geeko'] %}
  'salt_cluster:{{ salt_cluster }}':
    - match: grain
    - salt_cluster.{{ salt_cluster }}
    - salt_cluster.{{ salt_cluster }}.osfullname.{{ osfullname.replace(' ', '_') }}
  '{{ id }}':
    - id.{{ id.replace('.', '_') }}
  {% endif %}

{% from "macros.jinja" import valid_virt_cluster with context %}
{% set country = salt['grains.get']('country') %}
{% set domain = salt['grains.get']('domain') %}
{% set id = salt['grains.get']('id') %}
{% set osfullname = salt['grains.get']('osfullname') %}
{% set osmajorrelease = salt['grains.get']('osmajorrelease') %}
{% set roles = salt['grains.get']('roles', []) %}
{% set salt_cluster = salt['grains.get']('salt_cluster') %}
{% set virt_cluster = salt['grains.get']('virt_cluster') %}
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
  {% if virt_cluster in valid_virt_cluster() %}
  'virt_cluster:{{ virt_cluster }}':
    - match: grain
    - virt_cluster.{{ virt_cluster }}
  'G@virt_cluster:{{ virt_cluster }} and G@virtual:{{ virtual }}':
    - match: compound
    - virt_cluster.{{ virt_cluster }}.{{ virtual }}
  {% endif %}
  'virtual:{{ virtual }}':
    - match: grain
    - virtual.{{ virtual }}
  'country:{{ country }}':
    - match: grain
    - country.{{ country }}
  {% if domain and domain == 'infra.opensuse.org' %}
  'domain:{{ domain }}':
    - match: grain
    - domain.{{ domain.replace('.', '_') }}
  {% endif %}
  'osfullname:{{ osfullname }}':
    - match: grain
    - osfullname.{{ osfullname }}
  'osmajorrelease:{{ osmajorrelease }}':
    - match: grain
    - osmajorrelease.{{ osmajorrelease }}
  {% if salt_cluster in ['opensuse', 'geeko'] %}
  'salt_cluster:{{ salt_cluster }}':
    - match: grain
    - salt_cluster.{{ salt_cluster }}
    - salt_cluster.{{ salt_cluster }}.osfullname.{{ osfullname }}
  '{{ id }}':
    - id.{{ id.replace('.', '_') }}
  {% endif %}

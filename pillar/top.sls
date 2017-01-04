{% set country = salt['pillar.get']('country') %}
{% set domain = salt['grains.get']('domain') %}
{% set id = salt['grains.get']('id') %}
{% set osrelease = salt['grains.get']('osrelease') %}
{% set roles = salt['pillar.get']('roles', []) %}
{% set salt_cluster = salt['pillar.get']('salt_cluster', '') %}
{% set virt_cluster = salt['pillar.get']('virt_cluster', '') %}
{% set virtual = salt['grains.get']('virtual') %}

production:
  '*':
    - common
{% for role in roles %}
  'roles:{{ role }}':
    - match: grain
    - role.{{ role }}
{% endfor %}
{% if virt_cluster %}
  'virt_cluster:{{ virt_cluster }}:
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
{% if domain %}
  'domain:{{ domain }}':
    - match: grain
    - domain.{{ domain.replace('.', '_') }}
{% endif %}
  'osrelease:{{ osrelease }}':
    - match: grain
    - osrelease.{{ osrelease.replace('.', '_') }}
  'salt_cluster:{{ salt_cluster }}':
    - match: grain
    - salt_cluster.{{ salt_cluster }}
  '{{ id }}':
    - id.{{ id.replace('.', '_') }}

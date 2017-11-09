{% from "macros.jinja" import include_optional with context %}
{% set roles = salt['pillar.get']('grains:roles', []) %}

production:
  '*':
    - role.base
  {% for role in roles %}
  'roles:{{ role }}':
    - match: grain
    - role.{{ role }}
  {% endfor %}

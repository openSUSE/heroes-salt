{% from "macros.jinja" import include_optional with context %}
{% set roles = salt['pillar.get']('grains:roles', []) %}

{{ saltenv }}:
  '*':
    - role.base
  {% for role in roles %}
  'roles:{{ role }}':
    - match: grain
    {{ include_optional("role/{0}".format(role)) }}
  {% endfor %}

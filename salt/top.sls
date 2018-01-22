{% set roles = salt['grains.get']('roles', []) %}

{{ saltenv }}:
  '*':
    - role.base
  {% for role in roles %}
  'roles:{{ role }}':
    - match: grain
    - role.{{ role }}
  {% endfor %}

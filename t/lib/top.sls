
{% set roles = salt['grains.get']('roles', []) %}

{{ saltenv }}:
  "*":
    - testpreset
{% if (salt['grains.has_value']('roles')) %}
  {% for role in roles %}
  'roles:{{ role }}':
    - match: grain
    - ignore_missing: True
    - role.{{ role }}
  {% endfor %}
{% endif %}

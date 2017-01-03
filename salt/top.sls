{% set roles = salt['pillar.get']('roles', []) %}

production:
  '*':
    - role.base
{% for role in roles %}
  'roles:{{ role }}':
    - match: grain
    - role.{{ role }}
{% endfor %}

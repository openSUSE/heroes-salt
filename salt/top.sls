{% set roles = salt['pillar.get']('roles', []) %}

{{ saltenv }}:
  '*':
    - role.base
  {%- if roles | length %}
  '{{ grains['id'] }}':
  {%- for role in roles %}
    - role.{{ role }}
  {%- endfor %}
  {%- endif %}

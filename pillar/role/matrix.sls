{% if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.matrix
{% endif %}

profile:
  matrix:
    discord_client_id: 672058964707377152

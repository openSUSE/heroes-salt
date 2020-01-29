{% if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.matrix
{% endif %}

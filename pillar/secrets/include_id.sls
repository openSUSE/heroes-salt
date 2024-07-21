{%- if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.id.{{ grains['id'].replace('.', '_') }}
{%- else %}
# Secrets disabled through include_secrets
{%- endif %}

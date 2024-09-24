{%- if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.draupnir
{%- endif %}

sudoers:
  groups:
    draupnir-low-admins:
      {%- for action in ['restart', 'start', 'stop'] %}
      - '{{ grains['host'] }} = (root) /usr/bin/systemctl {{ action }} draupnir-bot'
      {%- endfor %}

# add members of draupnir-low-admins to these local groups as well
# (c|sh)ould be improved by fetching users from kanidm here
groups:
  synapse:
    members:
      - rorysys
  systemd-journal:
    members:
      - rorysys

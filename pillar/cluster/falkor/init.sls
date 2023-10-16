include:
  - .network
  - .firewall
  - .libvirt
  - .suse_ha
  {%- if salt['grains.get']('include_secrets', True) %}
  - secrets.cluster.falkor
  {%- endif %}

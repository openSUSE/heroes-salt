include:
  - .network
  - .firewall
  - .libvirt
  - .suse_ha
  {%- if salt['grains.get']('include_secrets', True) %}
  - secrets.cluster.falkor
  {%- endif %}

mine_functions:
  clusterip:
    mine_function: network.ip_addrs6
    interface: os-f-cluster
    cidr: fd4b:5292:d67e:1002::/64

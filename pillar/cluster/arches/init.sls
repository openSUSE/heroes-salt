{%- from 'macros.jinja' import smart %}

include:
  - .network
  - .suse_ha
  {%- if salt['grains.get']('include_secrets', True) %}
  - secrets.cluster.arches
  {%- endif %}

hostsfile:
  minions: arches*.infra.opensuse.org

mine_functions:
  clusterip:
    mine_function: network.ip_addrs6
    interface: os-a-cluster
    cidr: fda1:21af:580f:1703::/64

{{ smart([
      'sda',
      'sdb',
]) }}

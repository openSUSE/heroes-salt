{%- from 'macros.jinja' import smart %}

include:
  - .network
  - .suse_ha
  {%- if salt['grains.get']('include_secrets', True) %}
  - secrets.cluster.arches
  {%- endif %}

mine_functions:
  clusterip:
    mine_function: network.ip_addrs6
    interface: os-a-cluster
    cidr: fda1:21af:580f:1703::/64

nfs:
  mount:
    kvm_share:
      location: '"[fdb5:ae73:9cbd:1706::3]:/kvm"'
      mountpoint: /kvm
      opts:
        - defaults
        - sec=sys

{{ smart([
      'sda',
      'sdb',
]) }}

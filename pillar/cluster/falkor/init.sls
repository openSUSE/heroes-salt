{%- from 'macros.jinja' import smart %}

include:
  - .network
  - .firewall
  - .suse_ha
  {%- if salt['grains.get']('include_secrets', True) %}
  - secrets.cluster.falkor
  {%- endif %}

grains:
  virt_cluster: falkor-bare

hostsfile:
  minions: falkor*.infra.opensuse.org

mine_functions:
  clusterip:
    mine_function: network.ip_addrs6
    interface: os-f-cluster
    cidr: fd4b:5292:d67e:1002::/64

{{ smart([
      'sda',
      'sdb',
]) }}

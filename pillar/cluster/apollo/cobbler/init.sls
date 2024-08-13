{%- from 'macros.jinja' import bond, slave, smart %}

network:
  interfaces:

    # Physical interfaces
    {{ slave('ob0') }}
    {{ slave('ob1') }}

    # LACP bond
    {{ bond('ob', 'ob0', 'ob1') }}

    # VLAN interface for host connectivity
    os-ghr-c:
      etherdevice: bond-ob
      vlan_id: 1207
      firewall: false

{{ smart([
      'sda',
      'sdb',
]) }}

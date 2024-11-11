{%- from 'macros.jinja' import gateway_interfaces %}

network:
  interfaces:
    eth0:
      bootproto: none
      startmode: auto

    os-avalon-ct:
      vlan_id: 1701
      etherdevice: eth0

    os-p2p-pub:
      vlan_id: 1010
      etherdevice: eth0

    {{ gateway_interfaces('slc1') }}

  routes:
    default6:
      gateway: 2a07:de40:617f:201:ffff:ffff:ffff:ffff
    default4:
      gateway: 195.135.220.46

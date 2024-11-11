{%- from 'macros.jinja' import gateway_interfaces %}

network:
  interfaces:
    eth0:
      bootproto: none
      startmode: auto

    os-asgard:
      vlan_id: 1000
      etherdevice: eth0

    os-p2p-pub:
      vlan_id: 3201
      etherdevice: eth0

    {{ gateway_interfaces('prg2') }}

  routes:
    default6:
      gateway: 2a07:de40:b27f:201:ffff:ffff:ffff:ffff
    default4:
      gateway: 195.135.223.46
    2a07:de40:b27e:5001::/64:
      gateway: 2a07:de40:b27e:1102::a
    2a07:de40:b27e:5002::/64:
      gateway: 2a07:de40:b27e:1102::a

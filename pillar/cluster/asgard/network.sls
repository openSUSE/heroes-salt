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
      post_up_script: &ifscripts >-
        wicked:/usr/local/libexec/dopbr
        wicked:/usr/local/libexec/dotc
      pre_down_script: *ifscripts

    {{ gateway_interfaces('prg2') }}

  routes:
    default6:
      gateway: 2a07:de40:b27f:201:ffff:ffff:ffff:ffff
    default4:
      gateway: 195.135.223.46
    2a07:de40:b27e:4003::/64:
      gateway: 2a07:de40:b27e:1207::a
    2a07:de40:b27e:5001::/64:
      gateway: 2a07:de40:b27e:1102::a
    2a07:de40:b27e:5002::/64:
      gateway: 2a07:de40:b27e:1102::a
    192.168.67.0/24:  # defunct Provo
      options:
        - unreachable

profile:
  tc:
    interfaces:
      os-p2p-pub:
        max: 900Mbit
        default: 11
        # quantum calculation with default r2q of 10 causes "too big" warnings, is 1000 sensible?
        r2q: 1000
        classes:
          - id: '1:11'
            rate: 700Mbit
            ceil: 800Mbit
            prio: 1
          # => salt/files/nftables/asgard/base_shape/forward.nft
          - id: '1:17'
            rate: 50Mbit
            ceil: 60Mbit
            prio: 7

  pbr:
    tables:
      os-s2s:
        bind_interface: os-p2p-pub
        id: 201
        rules:
          to:
            - 2a07:de40:617f:201::11/128  # avalon1
            - 2a07:de40:617f:201::12/128  # avalon2

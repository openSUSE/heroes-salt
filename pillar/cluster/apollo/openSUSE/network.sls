{%- from 'macros.jinja' import bond, slave %}

network:
  interfaces:

    # Physical interfaces
    {{ slave('ob0') }}
    {{ slave('ob1') }}

    # LACP bond
    {{ bond('ob', 'ob0', 'ob1') }}

    # VLAN interface for host connectivity
    os-ghr-os:
      etherdevice: bond-ob
      vlan_id: 1208
      firewall: false

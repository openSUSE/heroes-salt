{%- from 'macros.jinja' import bond, slave %}

firewalld:
  zones:
    internal:
      interfaces:
        - os-ghr-c

network:
  interfaces:
    # Physical interfaces
    {{ slave('ob0') }}
    {{ slave('ob1') }}

    # LACP bond
    {{ bond('ob', 'ob0', 'ob1') }}

    os-ghr-c:
      etherdevice: bond-ob
      vlan_id: 1207
      firewall: false

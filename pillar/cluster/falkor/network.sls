{%- from 'macros.jinja' import bond, slave, vlantap %}

network:
  interfaces:

    # Physical interfaces
    {%- for interface in ['fib0', 'fib1', 'ob0', 'ob1'] %}
    {{ slave(interface) }}
    {%- endfor %}

    # LACP bonds
    {{ bond('ob', 'ob0', 'ob1') }}
    {{ bond('fib', 'fib0', 'fib1') }}

    # VLAN interfaces for host connectivity
    os-bare:
      etherdevice: bond-ob
      vlan_id: 1201
      firewall: false
    os-f-cluster:
      etherdevice: bond-ob
      vlan_id: 1002
      firewall: false
    os-f-nfs:
      etherdevice: bond-ob
      vlan_id: 3329
      firewall: false

    # VLAN interfaces for generic (non-VRRP) VM connectivity
    {%- for vlan_name, vlan_id in {
          'os-salt': 1200,
          'os-internal': 1203,
          'os-public': 1204,
          'os-mirror': 1205,
        }.items() %}
    {{ vlantap(vlan_name, vlan_id, 'bond-fib') }}
    {%- endfor %}

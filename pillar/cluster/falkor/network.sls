{%- from 'macros.jinja' import bond, slave, vlantap %}

network:
  interfaces:

    # Physical interfaces
    {%- for interface in ['fib0', 'fib2', 'ob0', 'ob1'] %}
    {{ slave(interface) }}
    {%- endfor %}

    # LACP bonds
    {{ bond('ob', 'ob0', 'ob1') }}
    {{ bond('fib', 'fib0', 'fib2') }}

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
    {%- set vlanmap = {
          'os-thor': 1100,
          'os-odin': 1102,
          'os-salt': 1200,
          'os-internal': 1203,
          'os-public': 1204,
          'os-mirror': 1205,
          'os-code': 1206,
          'os-mail': 1209,
          'os-kani': 1210,
          'os-netbox': 1211,
          'os-log': 1215,
        }
    %}
    {%- for vlan_name, vlan_id in vlanmap.items() %}
    {{ vlantap(vlan_name, vlan_id, 'bond-fib') }}
    {%- endfor %}

firewalld:
  zones:
    drop:
      interfaces:
        {%- for vlan_name in vlanmap.keys() %}
        - x-{{ vlan_name }}
        {%- endfor %}

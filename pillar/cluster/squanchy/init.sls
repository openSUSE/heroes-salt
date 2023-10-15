{%- from 'macros.jinja' import bond, slave, vlantap %}

network:
  interfaces:

    # Physical interfaces
    {%- for interface in ['mgmt0', 'mgmt1', 'ob0', 'ob1'] %}
    {{ slave(interface) }}
    {%- endfor %}

    # LACP bonds
    {{ bond('mgmt', 'mgmt0', 'mgmt1') }}
    {{ bond('ob', 'ob0', 'ob1') }}

    # VLAN interface for host connectivity
    os-bare:
      etherdevice: bond-ob
      vlan_id: 1201
      firewall: false

    # VLAN interface for devcon VM connectivity
    {{ vlantap('os-ipmi-ur', 1001, 'bond-mgmt') }}

    # VLAN interfaces for generic VM connectivity
    {%- for vlan_name, vlan_id in {
          'os-internal': 1203,
          'os-mirror': 1205,
          'os-salt': 1200,
          'os-s-warp': 1101,
          's-j-os-out': 3202,
          's-na-mgmt': 3339
        }.items() %}
    {{ vlantap(vlan_name, vlan_id, 'bond-ob') }}
    {%- endfor %}

{%- from 'macros.jinja' import bond, slave, vlantap %}

grains:
  virt_cluster: squanchy-bare

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
    {%- set vlanmap = {
          'os-thor': 1100,
          'os-internal': 1203,
          'os-mirror': 1205,
          'os-salt': 1200,
          'os-s-warp': 1101,
          's-j-os-out': 3202,
          's-na-mgmt': 3339
        }
    %}
    {%- for vlan_name, vlan_id in vlanmap.items() %}
    {{ vlantap(vlan_name, vlan_id, 'bond-ob') }}
    {%- endfor %}

firewalld:
  zones:
    drop:
      interfaces:
        {%- for vlan_name in vlanmap.keys() %}
        - x-{{ vlan_name }}
        {%- endfor %}

smartmontools:
  smartd:
    config:
      - /dev/sda
      - /dev/sdb
      - /dev/sdc
      - /dev/sdd

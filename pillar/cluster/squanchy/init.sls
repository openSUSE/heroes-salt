{%- from 'macros.jinja' import bond, default_gateway, slave, smart, vlantap, vlantapnetworks %}

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
    {%- set vlanmap_ur = {
          'mgmt': {
            'os-ipmi-ur': 1001,
          },
          'ob': {
            'os-asgard-m': 1003,
            's-j-os-out': 3202,
            's-na-mgmt': 3339,
          },
    } %}
    {%- for bond, vlans in vlanmap_ur.items() %}
      {%- for vlan_name, vlan_id in vlans.items() %}
    {{ vlantap(vlan_name, vlan_id, 'bond-' ~ bond) }}
      {%- endfor %}
    {%- endfor %}

    # VLAN interfaces for generic VM connectivity
    {%- set vlanlist_r = [
          'os-internal',
          'os-mirror',
          'os-s-warp',
          'os-salt',
          'os-thor',
        ]
    %}
    {{ vlantapnetworks(vlanlist_r, 'bond-ob', 'prg2') }}

  {{ default_gateway('prg2', 'openSUSE-bare') }}

firewalld:
  zones:
    drop:
      interfaces:
        {%- for vlan_name in vlanlist_r + vlanmap_ur['mgmt'] | list + vlanmap_ur['ob'] | list %}
        - x-{{ vlan_name }}
        {%- endfor %}

{{ smart([
      'sda',
      'sdb',
      'sdc',
      'sdd',
]) }}

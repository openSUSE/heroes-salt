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
    {{ vlantap('os-ipmi-ur', 1001, 'bond-mgmt') }}

    # VLAN interfaces for generic VM connectivity
    {%- set vlanlist_r = [
          'os-internal',
          'os-mirror',
          'os-s-warp',
          'os-salt',
          'os-thor',
          's-j-os-out',
          's-na-mgmt',
        ]
    %}
    {{ vlantapnetworks(vlanlist_r, 'bond-ob', 'prg2') }}

  {{ default_gateway('prg2', 'openSUSE-bare') }}

firewalld:
  zones:
    drop:
      interfaces:
        {%- for vlan_name in vlanlist_r %}
        - x-{{ vlan_name }}
        {%- endfor %}

{{ smart([
      'sda',
      'sdb',
      'sdc',
      'sdd',
]) }}

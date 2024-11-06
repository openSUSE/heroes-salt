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
      vlan_id: 1800
      firewall: false

    # TEMP for installation
    bootstrap:
      bootproto: dhcp
      etherdevice: bond-ob
      startmode: auto
      vlan_id: 1950
      zone: public

    # VLAN interface for devcon VM connectivity
    {{ vlantap('os-ipmi-ur', 1702, 'bond-mgmt') }}

    # VLAN interfaces for generic VM connectivity
    {%- set vlanmap = {
          'os-devcon': 1801,
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

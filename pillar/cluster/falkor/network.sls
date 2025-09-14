{%- from 'macros.jinja' import bond, default_gateway, slave, vlantapnetworks %}

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
    {%- set vlanlist_r = [
          'os-code',
          'os-code-dev',
          'os-internal',
          'os-kani',
          'os-kani-dev',
          'os-kani-ext',
          'os-log',
          'os-mail',
          'os-mirror',
          'os-monitor',
          'os-netbox',
          'os-odin',
          'os-public',
          'os-salt',
          'os-thor',
          'os-web',
        ]
    %}
    {{ vlantapnetworks(vlanlist_r, 'bond-fib', 'prg2') }}

  {{ default_gateway('prg2', 'openSUSE-bare') }}

firewalld:
  zones:
    drop:
      interfaces:
        {%- for vlan_name in vlanlist_r %}
        - x-{{ vlan_name }}
        {%- endfor %}

{%- from 'macros.jinja' import bond, slave, vlantap %}

network:
  interfaces:

    # Physical interaces
    {%- for interface in ['fib0', 'fib1', 'ob0', 'ob1'] %}
    {{ slave(interface) }}
    {%- endfor %}

    # LACP bonds
    # bond-fib explicitly receives bootproto=none as it's passed through to the Avalon VMs
    {{ bond('fib', 'fib0', 'fib1', 'none') }}
    {{ bond('ob', 'ob0', 'ob1') }}

    # VLAN interface for host connectivity
    os-bare:
      etherdevice: bond-ob
      vlan_id: 1800
      firewall: false

    # VLAN interfaces for generic VM connectivity
    {{ vlantap('os-avalon', 1700, 'bond-ob') }}

  {{ default_gateway('slc1', 'openSUSE-bare') }}

firewalld:
  enabled: true
  zones:
    drop:
      interfaces:
        - x-os-avalon
    internal:
      interfaces:
        - os-bare

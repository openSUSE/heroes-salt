{%- from 'macros.jinja' import bond, default_gateway, slave, vlantapnetworks %}

network:
  interfaces:

    # Physical interfaces
    {%- for interface in ['fib2', 'fib3', 'ob0', 'ob1'] %}
    {{ slave(interface) }}
    {%- endfor %}

    # LACP bonds
    {{ bond('ob', 'ob0', 'ob1', mtu=9216) }}
    {{ bond('fib', 'fib2', 'fib3', mtu=9216) }}

    # VLAN interfaces for host connectivity
    os-a-cluster:
      etherdevice: bond-ob
      vlan_id: 1703
      firewall: false
      mtu: 9216
    os-a-nfs:
      etherdevice: bond-ob
      vlan_id: 1706
      firewall: false
      mtu: 9000
    os-bare:
      etherdevice: bond-ob
      vlan_id: 1800
      firewall: false
      mtu: 1500

    # VLAN interfaces for generic VM connectivity
    {%- set vlanlist_r = [
          'os-dbginfod',
          'os-internal',
          'os-mircache',
          'os-mirror',
          'os-public',
        ]
    -%}
    {{ vlantapnetworks(vlanlist_r, 'bond-fib', 'slc1', 1500) }}

    # VLAN interfaces for unrouted VM connectivity
    {{ vlantap('os-mirror-bc', 1708, 'bond-fib', 9216) }}

  {{ default_gateway('slc1', 'openSUSE-bare') }}

firewalld:
  enabled: true
  zones:
    cluster:
      interfaces:
        - os-a-cluster
    drop:
      interfaces:
        {%- for vlan_name in vlanlist_r %}
        - x-{{ vlan_name }}
        {%- endfor %}
    main:
      interfaces:
        - os-bare
    nfs:
      interfaces:
        - os-a-nfs

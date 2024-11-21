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
    os-a-cluster:
      etherdevice: bond-ob
      vlan_id: 1703
      firewall: false
    os-a-nfs:
      etherdevice: bond-ob
      vlan_id: 1706
      firewall: false
    os-bare:
      etherdevice: bond-ob
      vlan_id: 1800
      firewall: false

    # VLAN interfaces for generic VM connectivity
    {%- set vlanlist_r = [
          'os-sif',
        ]
    -%}
    {{ vlantapnetworks(vlanlist_r, 'bond-fib', 'slc1') }}

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

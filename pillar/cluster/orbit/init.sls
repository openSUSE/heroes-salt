{%- from 'macros.jinja' import bond, slave, vlantap %}

grains:
  virt_cluster: orbit-bare

network:
  interfaces:

    # Physical interaces
    {%- for slave in ['ob0', 'ob1', 'fib0', 'fib1'] %}
    {{ slave }}:
      bootproto: none
      firewall: false
    {%- endfor %}

    # LACP bonds
    {{ bond('ob', 'ob0', 'ob1') }}
    {{ bond('fib', 'fib0', 'fib1') }}

    # VLAN interface for host connectivity
    os-bare:
      etherdevice: bond-ob
      vlan_id: 1201
      firewall: false

    # VLAN interfaces for generic (non-VRRP) VM connectivity
    {{ vlantap('os-internal', 1203, 'bond-ob') }}

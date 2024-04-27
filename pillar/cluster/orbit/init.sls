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
    # bond-ob implicitly receives bootproto=none as it's enslaved in a bridge
    {{ bond('ob', 'ob0', 'ob1') }}
    # bond-fib explicitly receives bootproto=none as it's passed through to the Asgard VMs
    {{ bond('fib', 'fib0', 'fib1', 'none') }}

    # Bridge for shared connectivity through onboard interfaces
    br0:
      bootproto: none
      bridge_ports: bond-ob
      firewall: false

    # VLAN interface for host connectivity
    os-bare:
      etherdevice: br0
      vlan_id: 1201
      firewall: false

    # VLAN interfaces for generic (non-VRRP) VM connectivity
    {{ vlantap('os-internal', 1203, 'bond-ob') }}

firewalld:
  enabled: true
  zones:
    drop:
      interfaces:
        - x-os-internal
    internal:
      interfaces:
        - os-bare

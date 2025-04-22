firewalld:
  zones:
    internal:
      interfaces:
        - os-ghr-c

network:
  interfaces:
    os-ghr-c:
      etherdevice: bond-ob
      vlan_id: 1207
      firewall: false

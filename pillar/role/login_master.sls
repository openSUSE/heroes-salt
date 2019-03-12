keepalived:
  vrrp_instance:
    VRRP_OPENSUSE_LOGIN2_PRIVATE_IPV4:
      priority: 110
      state: MASTER
      unicast_src_ip: 192.168.47.21
      unicast_peer:
        - 192.168.47.22
    VRRP_OPENSUSE_LOGIN2_PRIVATE_IPV6:
      priority: 110
      state: MASTER

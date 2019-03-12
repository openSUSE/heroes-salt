keepalived:
  vrrp_instance:
    VRRP_OPENSUSE_PRIVATE_IPV4:
      priority: 100
      state: BACKUP
      unicast_src_ip: 192.168.47.101
      unicast_peer:
        - 192.168.47.102
    VRRP_OPENSUSE_PRIVATE_IPV6:
      priority: 100
      state: BACKUP

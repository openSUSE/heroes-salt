keepalived:
  vrrp_instance:
    VRRP_OPENSUSE_PRIVATE:
      priority: 110
      state: MASTER
      unicast_src_ip: 192.168.47.102
      unicast_peer:
        - 192.168.47.101

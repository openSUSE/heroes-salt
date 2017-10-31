keepalived:
  vrrp_instances:
    VRRP_OPENSUSE_PRIVATE:
      state: MASTER
      priority: 110
      unicast_src_ip: 192.168.47.102
      unicast_peer:
        - 192.168.47.101

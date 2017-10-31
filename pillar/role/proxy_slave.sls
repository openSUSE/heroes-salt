keepalived:
  vrrp_instances:
    VRRP_OPENSUSE_PRIVATE:
      state: BACKUP
      priority: 100
      unicast_src_ip: 192.168.47.101
      unicast_peer:
        - 192.168.47.102

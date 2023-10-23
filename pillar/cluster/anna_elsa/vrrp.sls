keepalived:
  global_defs:
    router_id: OPENSUSE_NUE
  vrrp_sync_group:
    VRRP_OPENSUSE_PRIVATE_GROUP:
      group:
        - VRRP_OPENSUSE_PRIVATE_IPV4
        - VRRP_OPENSUSE_PRIVATE_IPV6
  vrrp_instance:
    VRRP_OPENSUSE_PRIVATE_IPV4:
      advert_int: 1
      authentication:
        auth_type: PASS
        # auth_pass included from pillar/secrets/role/proxy.sls
      interface: private
      notify: /usr/bin/keepalived_notify_monitoring.sh
      promote_secondaries: ''
      smtp_alert: ''
      virtual_ipaddress:
        - 192.168.47.4/24 dev private
        # proxy-nue.opensuse.org
        - 195.135.221.140/25 dev external
        # static.opensuse.org
        - 195.135.221.143/25 dev external
      virtual_router_id: 51
    VRRP_OPENSUSE_PRIVATE_IPV6:
      advert_int: 1
      authentication:
        auth_type: PASS
        # auth_pass included from pillar/secrets/role/proxy.sls
      interface: private
      notify: /usr/bin/keepalived_notify_monitoring.sh
      promote_secondaries: ''
      smtp_alert: ''
      virtual_ipaddress:
        # proxy-nue.opensuse.org
        - 2001:67c:2178:8::16/64 dev external
        # static.opensuse.org
        - 2001:67c:2178:8::18/64 dev external
      virtual_router_id: 51

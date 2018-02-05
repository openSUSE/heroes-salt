{% if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.proxy
{% endif %}

keepalived:
  global_defs:
    router_id: OPENSUSE_NUE
  vrrp_instance:
    VRRP_OPENSUSE_PRIVATE:
      advert_int: 1
      authentication:
        auth_type: PASS
        # auth_pass included from pillar/secrets/role/proxy.sls
      interface: private
      notify: /usr/bin/keepalived_notify_monitoring.sh
      promote_secondaries: ''
      smtp_alert: ''
      virtual_ipaddress:
        - 192.168.254.4/24 dev private
        - 192.168.47.4/24 dev private
        - 172.16.42.103/24 dev login
        # mirrordb.opensuse.org
        - 195.135.221.138/25 dev external
        - 2001:67c:2178:8::15/64 dev external
        # proxy-nue.opensuse.org
        - 195.135.221.140/25 dev external
        - 2001:67c:2178:8::16/64 dev external
        # static.opensuse.org
        - 195.135.221.143/25 dev external
        - 2001:67c:2178:8::18/64 dev external
      virtual_router_id: 51

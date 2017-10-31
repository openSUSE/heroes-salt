{% set host = salt['grains.get']('host') %}

include:
  - secrets.role.proxy

keepalived:
  global_defs:
    notification_email_from: keepalived+{{ host }}@opensuse.org
    notification_emails:
      - admin-auto@opensuse.org
    router_id: OPENSUSE_NUE
    smtp_alert: True
    smtp_connect_timeout: 30
    smtp_server: localhost
  vrrp_instances:
    VRRP_OPENSUSE_PRIVATE:
      interface: private
      virtual_router_id: 51
      advert_int: 1
      notify: /usr/bin/keepalived_notify_monitoring.sh
      authentication:
        auth_type: PASS
        # auth_pass included from pillar/secrets/role/proxy.sls
      virtual_addresses:
        - 192.168.254.4/24 dev private
        - 192.168.47.4/24 dev private
        - 172.16.42.103/24 dev external
        # mirrordb.opensuse.org
        - 195.135.221.138/25 dev external
        # proxy-nue.opensuse.org
        - 195.135.221.140/25 dev external
        - 2001:67c:2178:8::16/64 dev external
        # static.opensuse.org
        - 195.135.221.143/25 dev external
        - 2001:67c:2178:8::18/64 dev external
      promote_secondaries: True
zypper:
  packages:
    monitoring-plugins-keepalived: {}

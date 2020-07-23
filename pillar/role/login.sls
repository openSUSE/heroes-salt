{% if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.login
{% endif %}

keepalived:
  global_defs:
    router_id: OPENSUSE_LOGIN2_NUE
  vrrp_sync_group:
    VRRP_OPENSUSE_LOGIN2_PRIVATEGROUP:
      group:
        - VRRP_OPENSUSE_LOGIN2_PRIVATE_IPV4
        - VRRP_OPENSUSE_LOGIN2_PRIVATE_IPV6
  vrrp_instance:
    VRRP_OPENSUSE_LOGIN2_PRIVATE_IPV4:
      advert_int: 1
      authentication:
        auth_type: PASS
        # auth_pass included from pillar/secrets/role/login.sls
      interface: private
      notify: /usr/bin/keepalived_notify_monitoring.sh
      promote_secondaries: ''
      smtp_alert: ''
      virtual_ipaddress:
        # shuttle needed to connect to the LDAP server
        # login2-opensuse.suse.de
        - 149.44.161.63/25 dev shuttle
        # external IPs
        # login2.opensuse.org
        - 195.135.221.161/25 dev external
        # login IPs
        # daffy.login.infra.opensuse.org.
        - 172.16.42.3/24 dev login
        # private IPs
        # daffy.infra.opensuse.org.
        - 192.168.47.16/24 dev private
      virtual_router_id: 60
      virtual_routes:
        - 149.44.160.0/23 via 149.44.161.126 dev shuttle
        - 137.65.227.0/29 via 149.44.161.126 dev shuttle
        - 137.65.244.208/32 via 149.44.161.126 dev shuttle
        - 192.168.252.0/24 via 192.168.47.254 dev private
        - 192.168.253.0/24 via 192.168.47.254 dev private
        - default via 195.135.221.129 dev external
    VRRP_OPENSUSE_LOGIN2_PRIVATE_IPV6:
      advert_int: 1
      authentication:
        auth_type: PASS
        # auth_pass included from pillar/secrets/role/login.sls
      interface: private
      notify: /usr/bin/keepalived_notify_monitoring.sh
      promote_secondaries: ''
      smtp_alert: ''
      virtual_ipaddress:
        # external IPs
        # login2.opensuse.org
        - 2001:67c:2178:8::161/64 dev external
      virtual_router_id: 60
openldap:
  tls_reqcert: allow

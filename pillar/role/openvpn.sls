sssd:
  settings:
    sssd: True
    sssd_conf:
      domains:
        freeipa.infra.opensuse.org:
          enumerate: False
          id_provider: ldap
          ldap_group_uuid: entryuuid
          ldap_schema: rfc2307bis
          ldap_search_base: cn=users,cn=accounts,dc=infra,dc=opensuse,dc=org
          ldap_user_uuid: entryuuid
          ldap_tls_reqcert: allow
          ldap_uri: ldap://freeipa.infra.opensuse.org
      general_settings:
        config_file_version: 2
        domains: freeipa.infra.opensuse.org
        services: nss, pam
      services:
        nss:
          filter_group: root
          filter_users: root
        pam: {}

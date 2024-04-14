remove_old_ldap_auth_packages:
  pkg.removed:
    - pkgs:
        - cyrus-sasl-gssapi
        - libbasicobjects0
        - libcollection4
        - libdhash1
        - libini_config5
        - libldb2
        - libpath_utils1
        - libref_array1
        - libsss_certmap0
        - libsss_idmap0
        - libsss_nss_idmap0
        - libtdb1
        - sssd
        - sssd-common
        - sssd-krb5-common
        - sssd-ldap
        {%- if 'kanidm-server' not in pillar.get('roles', {}) %}
        - openldap2-client
        {%- endif %}

remove_old_ldap_auth_files:
  file.absent:
    - names:
        - /etc/sssd
        - /usr/local/bin/fetch_freeipa_ldap_sshpubkey.sh
        - /var/log/sssd

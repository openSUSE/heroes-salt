include:
  - sssd

{% for file in [account, auth, password, session] %}
/etc/pam.d/session-{{ file }}-pc:
  file.managed:
    - source: salt://profile/ldap/client/files/etc/pam.d/session-{{ file }}-pc
{% endif %}

/usr/local/bin/fetch_freeipa_ldap_sshpubkey.sh
  file.managed:
    - source: salt://profile/ldap/client/files/usr/local/bin/fetch_freeipa_ldap_sshpubkey.sh
    - mode: 0755

/etc/openldap/ldap.conf
  file.managed:
    - source: salt://profile/ldap/client/files/etc/openldap/ldap.conf

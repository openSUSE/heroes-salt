include:
  - openldap.client
  - sssd

/usr/local/bin/fetch_freeipa_ldap_sshpubkey.sh:
  file.managed:
    - source: salt://profile/ldap/client/files/usr/local/bin/fetch_freeipa_ldap_sshpubkey.sh
    - mode: '0755'

{%- for setting in ['passwd', 'group'] %}
/etc/nsswitch.conf_{{ setting }}:
  file.replace:
    - name: /etc/nsswitch.conf
    - pattern: ^{{ setting }}:.*$
    - repl: '{{ setting }}: compat sss'
{%- endfor %}


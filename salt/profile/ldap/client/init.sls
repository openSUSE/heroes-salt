include:
  - sssd

/usr/local/bin/fetch_freeipa_ldap_sshpubkey.sh:
  file.managed:
    - source: salt://profile/ldap/client/files/usr/local/bin/fetch_freeipa_ldap_sshpubkey.sh
    - mode: 0755

# clear legacy custom PAM configuration; step can be removed later
reset_pam:
  cmd.run:
    - name: "{ rpm -ql pam-config | grep ^/etc ; rpm -qf /etc/pam.d/* | awk '/is not owned by any package/{ print $2 }' ; } | xargs -t rm"
    - onlyif: grep -Frm1 'Managed by Salt' /etc/pam.d

{%- for module, count in {'mkhomedir': 1, 'sss': 4, 'unix': 4}.items() %}
configure_pam_{{ module }}:
  cmd.run:
    - name: pam-config -a --{{ module }}
    - unless: test $(pam-config -q --{{ module }} | wc -l) = {{ count }}
{%- endfor %}

{% for setting in ['passwd', 'group'] %}
/etc/nsswitch.conf_{{setting}}:
  file.replace:
    - name: /etc/nsswitch.conf
    - pattern: ^{{setting}}:.*$
    - repl: '{{setting}}: compat sss'
{% endfor %}

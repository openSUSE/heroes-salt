include:
  - zypper.packages
  - .legacy

{%- for setting in ['passwd', 'group'] %}
/etc/nsswitch.conf_{{ setting }}:
  file.replace:
    - name: /etc/nsswitch.conf
    - pattern: ^{{ setting }}:.*$
    - repl: '{{ setting }}: compat kanidm'
{%- endfor %}

kanidm_config:
  file.managed:
    - names:
        - /etc/kanidm/config:
            - source: salt://profile/kanidm/client/files/etc/kanidm/config
        - /etc/kanidm/unixd:
            - source: salt://profile/kanidm/client/files/etc/kanidm/unixd
        - /etc/pam.d/common-account:
            - source: salt://profile/kanidm/client/files/etc/pam.d/common-account
        - /etc/pam.d/common-auth:
            - source: salt://profile/kanidm/client/files/etc/pam.d/common-auth
        - /etc/pam.d/common-session:
            - source: salt://profile/kanidm/client/files/etc/pam.d/common-session
        - /etc/pam.d/common-password:
            - source: salt://profile/kanidm/client/files/etc/pam.d/common-password
    - follow_symlinks: False
    - mode: '0644'
    - template: jinja
    - require:
        - pkg: zypper_packages

kanidm-unixd.service:
  service.running:
    - name: kanidm-unixd
    - enable: True
    - watch:
        - file: /etc/kanidm/config
        - file: /etc/kanidm/unixd
    - require:
        - pkg: zypper_packages

kanidm-unixd-tasks.service:
  service.running:
    - name: kanidm-unixd-tasks
    - enable: True
    - require_in:
        # to ensure sssd is removed/stopped
        - pkg: remove_old_ldap_auth_packages

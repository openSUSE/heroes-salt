include:
  - zypper.packages
  - .legacy

{%- if grains['osrelease'] | float >= 16 %}
/etc/nsswitch.conf_copy:
  file.copy:
    - name: /etc/nsswitch.conf
    - source: /usr/etc/nsswitch.conf
    - preserve: True
    - require_in:
        - file: /etc/nsswitch.conf_passwd
        - file: /etc/nsswitch.conf_group
{%- endif %}

{%- for setting in ['passwd', 'group'] %}
/etc/nsswitch.conf_{{ setting }}:
  file.replace:
    - name: /etc/nsswitch.conf
    - ignore_if_missing: {{ opts['test'] }}
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
    - require:
        - service: kanidm-unixd.service
        - pkg: remove_old_ldap_auth_packages
        - pkg: zypper_packages

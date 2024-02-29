include:
  - zypper.packages

# TODO: Uncomment when ready to change to kanidm.
#
{%- for setting in ['passwd', 'group'] %}
/etc/nsswitch.conf_{{ setting }}:
  file.replace:
    - name: /etc/nsswitch.conf
    - pattern: ^{{ setting }}:.*$
    - repl: '{{ setting }}: compat kanidm'
{%- endfor %}

/etc/kanidm/config:
  file.managed:
    - template: jinja
    - source: salt://profile/kanidm/client/files/etc/kanidm/config
    - mode: '0644'

/etc/kanidm/unixd:
  file.managed:
    - template: jinja
    - source: salt://profile/kanidm/client/files/etc/kanidm/unixd
    - mode: '0644'

/etc/pam.d/common-account:
  file.managed:
    - template: jinja
    - source: salt://profile/kanidm/client/files/etc/pam.d/common-account
    - mode: '0644'
    - follow_symlinks: False

/etc/pam.d/common-auth:
  file.managed:
    - template: jinja
    - source: salt://profile/kanidm/client/files/etc/pam.d/common-auth
    - mode: '0644'
    - follow_symlinks: False

/etc/pam.d/common-session:
  file.managed:
    - template: jinja
    - source: salt://profile/kanidm/client/files/etc/pam.d/common-session
    - mode: '0644'
    - follow_symlinks: False

/etc/pam.d/common-password:
  file.managed:
    - template: jinja
    - source: salt://profile/kanidm/client/files/etc/pam.d/common-password
    - mode: '0644'
    - follow_symlinks: False

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
      - service: kanidm-unixd

sssd.service:
  service.dead:
    - name: sssd
    - disable: True

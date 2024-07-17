include:
  - zypper.packages

/etc/sysconfig/dccifd:
  suse_sysconfig.sysconfig:
    - key_values:
        ARGS: >-
          -l /var/log/dcc
          -p /run/dcc/dccifd.sock
          -t CMN,2,4
    - require:
        - pkg: zypper_packages

{%- for ip in ['127.0.0.1', '::1'] %}
/var/lib/dcc/whitecommon_ok_{{ ip }}:
  file.uncomment:
    - name: /var/lib/dcc/whitecommon
    - regex: ^ok\tip\t{{ ip }}$
    - watch_in:
        - service: dccifd
{%- endfor %}

/var/lib/dcc/whiteclnt:
  file.managed:
    - contents:
        - option log-all
        - option DCC-reps-on
        - include whitecommon
        - ok ip 2a07:de40:b27e:1209::98
        - ok ip 2a07:de40:b27e:1209::11
        - ok ip 2a07:de40:b27e:1209::12
        - ok env_to postmaster@opensuse.org
        - ok env_to postmaster
        - many substitute helo example.com
        - many substitute helo localhost.localdomain
        - many substitute helo smtp.localhost.localdomain
        - many substitute helo test.com
        - many substitute helo unknown
    - watch_in:
        - service: dccifd

dccifd:
  service.running:
    - enable: true
    - watch:
        - suse_sysconfig: /etc/sysconfig/dccifd

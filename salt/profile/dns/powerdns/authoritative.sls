# here only custom scripts are managed, pdns configuration is done through the formula

profile_dns_powerdns_authoritative_scripts:
  file.managed:
    - names:
        - /usr/local/bin/notify_all.sh:
            - source: salt://{{ slspath }}/files/usr/local/bin/notify_all.sh.jinja
    - template: jinja
    - mode: '0750'

powerdns:
  service.running:
    - name: pdns
    - enable: True
    - require:
        - file: powerdns

powerdns_config:
  file.managed:
    - name: /etc/pdns/pdns.conf
    - source: salt://profile/nameserver/files/pdns_slave.conf
    - user: root
    - group: root
    - mode: 600
    - watch_in:
      - service: powerdns

include:
  {%- if salt['grains.get']('include_secrets', True) %}
  - secrets.role.nameserver.secondary
  {%- endif %}

powerdns:
  config:
    allow-notify-from: 192.168.47.51/32 # chip
    autosecondary: 'yes'
    launch: gsqlite3
    setgid: pdns
    setuid: pdns
    slave: 'yes'
    webserver: 'yes'
    webserver-address: {{ grains['fqdn_ip6'] }}
    webserver-allow-from: 2a07:de40:b27e:1100::a/128
    webserver-hash-plaintext-credentials: 'yes'
    webserver-port: 8080
    gsqlite3-database: /var/lib/pdns/slave.db
    gsqlite3-pragma-synchronous: 0
    gsqlite3-pragma-foreign-keys: 1
    gsqlite3-dnssec: 1

zypper:
  packages:
    sqlite3: {}

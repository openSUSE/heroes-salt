include:
  - .common.powerdns
  {%- if salt['grains.get']('include_secrets', True) %}
  - secrets.role.nameserver.secondary
  {%- endif %}

powerdns:
  config:
    allow-notify-from: 2a07:de40:b27e:1203::15/128 # chip
    autosecondary: 'yes'
    launch: gsqlite3
    setgid: pdns
    setuid: pdns
    slave: 'yes'
    gsqlite3-database: /var/lib/pdns/slave.db
    gsqlite3-pragma-synchronous: 0
    gsqlite3-pragma-foreign-keys: 1
    gsqlite3-dnssec: 1

  database:
    supermasters:
      - address: 2a07:de40:b27e:1203::15  # chip
        name: prg-ns1.infra.opensuse.org
      - address: 2a07:de40:b27e:1203::15
        name: prg-ns2.infra.opensuse.org
      - address: 2a07:de40:b27e:1203::15
        name: chip.infra.opensuse.org
      - address: 2a07:de40:b27e:1203::15
        name: ns1.opensuse.org

zypper:
  packages:
    sqlite3: {}

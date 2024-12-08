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
    secondary: 'yes'
    gsqlite3-database: /var/lib/pdns/slave.db
    gsqlite3-pragma-synchronous: 0
    gsqlite3-pragma-foreign-keys: 1
    gsqlite3-dnssec: 1

  database:
    supermasters:
      {%- for ns in [
                      'chip.infra',
                      'prg-ns1.infra',
                      'prg-ns2.infra',
                      'slc-ns1.infra',
                      'slc-ns2.infra',
                      'ns1',
                    ]
      %}
      - address: 2a07:de40:b27e:1203::15  # chip
        name: {{ ns }}.opensuse.org
      {%- endfor %}

powerdns:
  config:
    allow-axfr-ips: '137.65.249.1/32,127.0.0.0/8,::1'
    also-notify: '137.65.249.1'
    launch: 'gsqlite3'
    gsqlite3-database: '/var/lib/pdns/superslave.db'
    gsqlite3-pragma-synchronous: '0'
    gsqlite3-pragma-foreign-keys: '1'
    only-notify: '137.65.249.1/32'
    slave: 'yes'
    slave-renotify: 'yes'

zypper:
  packages:
    sqlite3: {}

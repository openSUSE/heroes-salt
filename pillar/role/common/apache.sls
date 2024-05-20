apache_httpd:
  modules:
    - status
  configs:
    log:
      SetEnvIf:
        Request_URI:
          ^/check.txt$: donotlog
    tls:
      SSLSessionTickets: false
      SSLStaplingCache: '"shmcb:logs/ssl_stapling(32768)"'
      SSLUseStapling: true
  vhosts:
    status:
      listen: ipv6-localhost:8181
      Location:
        /server-status:
          SetHandler: server-status

prometheus:
  wanted:
    component:
      - apache_exporter
  pkg:
    component:
      apache_exporter:
        name: false
        environ:
          args:
            scrape_uri: http://[::1]:8181/server-status/?auto
        service:
          name: prometheus-apache_exporter

zypper:
  packages:
    golang-github-lusitaniae-apache_exporter:
      fromrepo: openSUSE:infrastructure

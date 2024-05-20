apache_httpd:
  modules:
    - status
  configs:
    log:
      SetEnvIf:
        Request_URI:
          ^/check.txt$: donotlog
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
        name: golang-github-lusitaniae-apache_exporter
        environ:
          args:
            scrape_uri: http://[::1]:8181/server-status/?auto
        service:
          name: prometheus-apache_exporter

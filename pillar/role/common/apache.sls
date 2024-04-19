apache:
  purge: True
  global:
    SetEnvIfs:
      - attribute: Request_URI
        regex: ^/check.txt$
        variables: donotlog
    CustomLog: /var/log/apache2/access_log
    LogFormat: combined env=!dontlog
  sites:
    status:
      interface: ipv6-localhost:8181
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
            scrape_uri: http://ipv6-localhost:8181/server-status/?auto
        service:
          name: prometheus-apache_exporter

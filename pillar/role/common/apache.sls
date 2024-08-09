{%- set country = salt['grains.get']('country', 'cz') %}

apache_httpd:
  modules:
    - status
  configs:
    log:
      SetEnvIf:
        Request_URI:
          ^/check.txt$: donotlog
      SetEnvIfExpr:
         '"-R ''::1'' && req(''User-Agent'') =~ m#^Prometheus-Apache-Exporter/\d+\.\d+\.\d+$#"': donotlog_exporter
    remote:
      RemoteIPHeader: X-Forwarded-For
      RemoteIPTrustedProxy:
        {%- if country == 'cz' %}
        - 2a07:de40:b27e:1204::11
        - 2a07:de40:b27e:1204::12
        {%- elif country == 'de' %}
        - 192.168.87.5
        {%- elif country == 'us' %}
        - 192.168.67.1
        - 192.168.67.2
        - 192.168.67.3
        {%- endif %}
    tls:
      SSLSessionTickets: false
      SSLStaplingCache: '"shmcb:logs/ssl_stapling(32768)"'
      SSLUseStapling: true
  vhosts:
    status:
      listen: ipv6-localhost:8181
      CustomLog:
        env: =!donotlog_exporter
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

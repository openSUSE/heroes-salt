{%- from 'common/haproxy/map.jinja' import options, server, errorfiles, check_txt -%}

haproxy:
  backends:
    redirect_www_o_o:
      redirects: code 301 location https://www.opensuse.org/
    error_403:
      mode: http
      options: ['tcpka']
      httprequests: set-log-level silent
      extra:
        - errorfile 503 {{ errorfiles }}403.html.http
    download:
      options:
        - forwardfor header X-Forwarded-999
        - tcpka
      {{ server('download', '195.135.221.134') }}
    download-private:
      {{ options() }}
      {{ server('download-private', '192.168.47.73') }}
    smt:
      {{ options() }}
      {{ server('smt-internal', '195.135.221.141') }}
    conncheck:
      mode: http
      options: ['tcpka']
      httprequests: set-log-level silent
      extra:
        - errorfile 503 {{ errorfiles }}conncheck.txt.http
    mirrorlist:
      {{ options() }}
      {{ server('olaf', '192.168.47.17') }}
    mirrorcache:
      {{ options() }}
      {{ server('mirrorcache', '192.168.47.23', 3000) }}
    mirrorcache-eu:
      {{ options() }}
      {{ server('mirrorcache2', '192.168.47.28', 3000) }}
    hydra:
      stats:
        enable: true
        hide-version: ''
        uri: /
        refresh: 5s
        realm: Monitor
        auth: '"$STATS_USER":"$STATS_PASSPHRASE"'
    jenkins:
      options:
        - forwardfor
        - httpchk HEAD / HTTP/1.1\r\nHost:\ ci.opensuse.org
      {{ server('ci-opensuse', '192.168.47.77', 8080) }}
    security_txt:
      mode: http
      options:
        - tcpka
      httprequests: set-log-level silent
      extra:
        - errorfile 503 {{ errorfiles }}security.txt.http
    via_atlas:
      {{ options() }}
      {{ server('proxy-prg2', '172.16.164.5', 443, extra_check='ssl verify required verifyhost proxy-prg2.infra.opensuse.org check-sni proxy-prg2.infra.opensuse.org sni str(proxy-prg2.infra.opensuse.org) ca-file /usr/share/pki/trust/anchors/stepca-opensuse-ca.crt.pem') }}

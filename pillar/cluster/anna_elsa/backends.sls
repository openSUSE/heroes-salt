{%- from 'common/haproxy/map.jinja' import options, server, errorfiles, check_txt, httpcheck -%}

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
        - httpchk
      {{ httpcheck('ci.opensuse.org', 200) }}
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

{%- from 'common/haproxy/map.jinja' import options, server, errorfiles, check_txt -%}

haproxy:
  backends:
    redirect_www_o_o:
      redirects: code 301 location https://www.opensuse.org/
    status:
      mode: tcp
      options:
        - ssl-hello-chk
      servers:
        {%- for status_server, status_config in {'status1': '100', 'status2': '80 backup', 'status3': '90 backup'}.items() %}
        {{ server(status_server, status_server ~ '.opensuse.org', 443, extra_extra='inter 60000 weight ' ~ status_config, header=False) }}
        {%- endfor %}
    svn:
      {{ options() }}
      {{ server('svn', '192.168.47.25') }}
    rpmlint:
      extra: errorfile 503 {{ errorfiles }}downtime.xml.http {#- why a xml for api.o.o ? #}
      timeouts:
        - check 30s
        - server 30m
      {{ options() }}
      {{ server('rpmlint', '192.168.47.53', extra_extra='inter 5000') }}
    error_403:
      mode: http
      options: ['tcpka']
      httprequests: set-log-level silent
      extra:
        - errorfile 503 {{ errorfiles }}403.html.http
    osccollab:
      mode: http
      {{ options ('httpchk OPTIONS /check.txt HTTP/1.1\r\nHost:\ osc-collab.opensuse.org') }}
      {{ server('osccollab2', '192.168.47.64') }}
    openqa:
      {{ options() }}
      {{ server('openqa1', '192.168.47.13') }}
    redmine_test:
      {{ options ('httpchk HEAD / HTTP/1.1\r\nHost:\ progress.opensuse.org') }}
      {{ server('progress', '192.168.47.8', extra_extra='maxconn 16') }}
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
    mickey:
      {{ options() }}
      {{ server('mickey', '192.168.47.36', 443, extra_check='ssl verify none') }}
      {#- original had the mickey check port set to 80 - my macro does not support checking a different port, I assume the original was a mistake #}
    freeipa:
      {{ options() }}
      {{ server('freeipa', '192.168.47.65', 443, extra_check='ssl ca-file /etc/haproxy/freeipa-ca.crt') }}
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
    metrics:
      {{ options() }}
      {{ server('metrics', '192.168.47.31', 3000) }}
    obsreview: {#- to-do: investigate; port 80 only serves 404 #}
      {{ options() }}
      {{ server('obsreview', '192.168.47.39') }}
    security_txt:
      mode: http
      options:
        - tcpka
      httprequests: set-log-level silent
      extra:
        - errorfile 503 {{ errorfiles }}security.txt.http
    wip:
      mode: http
      extra: errorfile 503 {{ errorfiles }}fourohfour.html.http
      httprequests: set-log-level silent
    via_atlas:
      {{ options() }}
      {{ server('proxy-prg2', '172.16.164.5', 443, extra_check='ssl verify required verifyhost proxy-prg2.infra.opensuse.org check-sni proxy-prg2.infra.opensuse.org sni str(proxy-prg2.infra.opensuse.org) ca-file /usr/share/pki/trust/anchors/stepca-opensuse-ca.crt.pem') }}

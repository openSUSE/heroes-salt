{%- from 'common/haproxy/map.jinja' import options, server, errorfiles, check_txt -%}

haproxy:
  backends:
    redirect_www_o_o:
      redirects: code 301 location https://www.opensuse.org/
    community2:
      {{ options('httpchk OPTIONS /check.txt HTTP/1.1\r\nHost:\ factory-dashboard.opensuse.org') }}
      mode: http
      {{ server('community2', '192.168.47.79') }}
    status:
      mode: tcp
      options:
        - ssl-hello-chk
      servers:
        {%- for status_server, status_config in {'status1': '100', 'status2': '80 backup', 'status3': '90 backup'}.items() %}
        {{ server(status_server, status_server ~ '.opensuse.org', 443, extra_extra='inter 60000 weight ' ~ status_config, header=False) }}
        {%- endfor %}
    community:
      {{ options ('httpchk OPTIONS / HTTP/1.1\r\nHost:\ community.opensuse.org') }}
      {{ server('community', '192.168.47.6') }}
    svn:
      {{ options() }}
      {{ server('svn', '192.168.47.25') }}
    dale:
      {{ options('httpchk HEAD /robots.txt HTTP/1.1\r\nHost:\ events.opensuse.org') }}
      {{ server('dale', '192.168.47.52', 80) }}
    kubic:
      {{ options ('httpchk HEAD /check.txt HTTP/1.1\r\nHost:\ kubic.opensuse.org') }}
      {{ server('kubic', '192.168.47.30') }}
    mailman3:
      acls:
        - is_lists_test hdr_reg(host) -i (.*)-test\.opensuse\.org
      httprequests: {#- is lists-test.o.o still needed ? #}
        - replace-header HOST (.*)-test(.*) \1\2 if is_lists_test
      {{ options() }}
      {{ server('mailman3', '192.168.47.80', extra_extra='inter 30000') }}
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
    etherpad:
      {{ options() }}
      extra:
        - errorfile 503 {{ errorfiles }}downtime.html.http
        - http-response del-header X-Frame-Options
      timeouts:
        - check 30s
        - server 30m
      {{ server('etherpad', '192.168.47.56', 9001, extra_extra='inter 5000') }}
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
    redmine:
      {{ options ('httpchk HEAD / HTTP/1.1\r\nHost:\ progress.opensuse.org') }}
      {{ server('progressoo', '192.168.47.34', 3001, extra_extra='maxconn 16') }}
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
    opi_proxy:
      mode: http
      {{ options() }}
      {{ server('opi_proxy', '192.168.47.50', extra_extra='inter 5000') }}
    pagure:
      mode: http
      {{ options() }}
      {{ server('pagure', '192.168.47.84', extra_extra='inter 5000') }}
    pagure_ssh:
      mode: tcp
      {{ server('pagure_ssh', '192.168.47.84', 22, check=None) }}
    gccstats:
      {{ options() }}
      {{ server('gccstats', '192.168.47.71') }}
    nuka:
      {{ options ('httpchk HEAD /static/weblate-128.png HTTP/1.1\r\nHost:\ l10n.opensuse.org') }}
      {{ server('nuka', '192.168.47.62') }}
    freeipa:
      {{ options() }}
      {{ server('freeipa', '192.168.47.65', 443, extra_check='ssl ca-file /etc/haproxy/freeipa-ca.crt') }}
    conncheck:
      mode: http
      options: ['tcpka']
      httprequests: set-log-level silent
      extra:
        - errorfile 503 {{ errorfiles }}conncheck.txt.http
    deadservices:
      options: ['tcpka']
      mode: http
      httprequests: set-log-level silent
      extra:
        - errorfile 503 {{ errorfiles }}deprecated.html.http
    hackweek:
      mode: http
      {{ options() }}
      {{ server('dale_hackweek', '192.168.47.52', 81) }}
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
    pinot:
      {{ options() }}
      {{ server('pinot', '192.168.47.11') }}
    riesling:
      {{ options() }}
      {{ server('riesling', '192.168.47.42') }}
    forums:
      {{ options() }}
      {{ server('discourse01', '192.168.47.83') }}
    tsp:
      {{ options() }}
      {{ server('tsp', '192.168.47.9') }}
    elections:
      {{ options() }}
      {{ server('elections2', '192.168.47.32') }}
    jenkins:
      options:
        - forwardfor
        - httpchk HEAD / HTTP/1.1\r\nHost:\ ci.opensuse.org
      {{ server('ci-opensuse', '192.168.47.77', 8080) }}
    metrics:
      {{ options() }}
      {{ server('metrics', '192.168.47.31', 3000) }}
    lnt:
      {{ options() }}
      {{ server('lnt', '192.168.47.35', 8080) }}
      httprequests:
      - set-header X-Forwarded-Host %[req.hdr(Host)]
      - set-header X-Forwarded-Proto https
      extra: timeout server 300s
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
    matrix:
      {{ options() }}
      {{ server('matrix', '192.168.47.78', 8008) }}
    chat:
      {{ options() }}
      {{ server('matrix', '192.168.47.78') }}
    wip:
      mode: http
      extra: errorfile 503 {{ errorfiles }}fourohfour.html.http
      httprequests: set-log-level silent
    man:
      {{ options() }}
      {{ server('man', '192.168.47.29') }}

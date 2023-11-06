{%- from 'common/haproxy/map.jinja' import errorfiles, narwals, options, server %}

haproxy:
  backends:
    chat:
      {{ options() }}
      {{ server('matrix', '2a07:de40:b27e:1203::b40') }}
    community:
      {{ options ('httpchk OPTIONS / HTTP/1.1\r\nHost:\ community.opensuse.org') }}
      {{ server('community', '2a07:de40:b27e:1203::128') }}
    community2:
      {{ options('httpchk OPTIONS /check.txt HTTP/1.1\r\nHost:\ factory-dashboard.opensuse.org') }}
      mode: http
      {{ server('community2', '2a07:de40:b27e:1203::129') }}
    dale:
      {{ options('httpchk HEAD /robots.txt HTTP/1.1\r\nHost:\ events.opensuse.org') }}
      {{ server('dale', '2a07:de40:b27e:1203::b16', 80) }}
    error_403:
      mode: http
      options:
        - tcpka
      httprequests: set-log-level silent
      extra:
        - errorfile 503 {{ errorfiles }}403.html.http
    elections:
      {{ options() }}
      {{ server('elections2', '2a07:de40:b27e:1203::b41') }}
    etherpad:
      {{ options() }}
      extra:
        - errorfile 503 {{ errorfiles }}downtime.html.http
        - http-response del-header X-Frame-Options
      timeouts:
        - check 30s
        - server 30m
      {{ server('etherpad', '2a07:de40:b27e:1203::b18', 9001, extra_extra='inter 5000') }}
    gccstats:
      {{ options() }}
      {{ server('gccstats', '2a07:de40:b27e:1203::b45') }}
    hackweek:
      mode: http
      {{ options() }}
      {{ server('dale_hackweek', '2a07:de40:b27e:1203::b16', 81) }}
    jekyll:
      {{ options('httpchk OPTIONS / HTTP/1.1\r\nHOST:\ search.opensuse.org') }}
      {{ server('jekyll', '2a07:de40:b27e:1203::e1') }}
      acls:
        - is_jekyll_test          hdr_reg(host) -i (.*)-test\.opensuse\.org
      extra: http-request replace-header HOST (.*)-test(.*) \1\2 if is_jekyll_test
    limesurvey:
      {{ options() }}
      {{ server('limesurvey', '2a07:de40:b27e:1203::b4', extra_extra='inter 5000') }}
    lnt:
      {{ options() }}
      {{ server('lnt', '2a07:de40:b27e:1203::b42', 8080) }}
      httprequests:
      - set-header X-Forwarded-Host %[req.hdr(Host)]
      - set-header X-Forwarded-Proto https
      extra: timeout server 300s
    man:
      {{ options() }}
      {{ server('man', '2a07:de40:b27e:1203::130') }}
    matomo:
      {{ options() }}
      {{ server('matomo', '2a07:de40:b27e:1203::b19') }}
    matrix:
      {{ options() }}
      {{ server('matrix', '2a07:de40:b27e:1203::b40', 8008) }}
    minio:
      {{ options() }}
      {{ server('minio', '2a07:de40:b27e:1203::c1') }}
    monitor:
      {{ options ('httpchk HEAD /check.txt HTTP/1.1\r\nHost:\ monitor.opensuse.org') }}
      {{ server('monitor', '2a07:de40:b27e:64::c0a8:2f07', extra_extra='inter 30000') }}
    monitor_grafana:
      {{ options() }}
      {{ server('grafana', '2a07:de40:b27e:64::c0a8:2f07', 3000, extra_extra='inter 30000') }}
    nuka:
      {{ options ('httpchk HEAD /static/weblate-128.png HTTP/1.1\r\nHost:\ l10n.opensuse.org') }}
      {{ server('nuka', '2a07:de40:b27e:1203::b44') }}
    paste:
      {{ options() }}
      {{ server('paste', '2a07:de40:b27e:1203::c2') }}
    pinot:
      {{ options() }}
      {{ server('pinot', '2a07:de40:b27e:1203::b15') }}
    redirect_www_o_o:
      redirects: code 302 location https://www.opensuse.org/
    redmine:
      {{ options ('httpchk HEAD / HTTP/1.1\r\nHost:\ progress.opensuse.org') }}
      {{ server('progressoo', '2a07:de40:b27e:1203::b17', 3001, extra_extra='maxconn 16') }}
    riesling:
      {{ options() }}
      {{ server('riesling', '2a07:de40:b27e:1203::b2') }}
    security_txt:
      mode: http
      options:
        - tcpka
      httprequests: set-log-level silent
      extra:
        - errorfile 503 {{ errorfiles }}security.txt.http
    staticpages:
      {{ options('httpchk OPTIONS / HTTP/1.1\r\nHost:\ static.opensuse.org') }}
      balance: roundrobin
      mode: http
      servers:
        {%- for static_server, address in narwals.items() %}
        {{ server(static_server, address, 80, header=False) }}
        {%- endfor %}
    tsp:
      {{ options() }}
      {{ server('tsp', '2a07:de40:b27e:1203::b20') }}
    www_openid_ldap:
      {{ options() }}
      {{ server('ldap-proxy', '2a07:de40:b27e:64::c0a8:2f03') }}
      mode: http

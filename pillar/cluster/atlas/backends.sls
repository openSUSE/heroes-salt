{%- from 'common/haproxy/map.jinja' import errorfiles, narwals, options, server, httpcheck %}

haproxy:
  backends:
    calendar:
      {{ options() }}
      {{ server('calendar', '2a07:de40:b27e:1203::b51') }}
    community: {#- community points to httpd on community2 #}
      {{ options ('httpchk') }}
      {{ httpcheck('community.opensuse.org', 200, method='options') }}
      {{ server('community', '2a07:de40:b27e:1203::129', 8080) }}
    community2: {#- community2 points to nginx on community2 #}
      {{ options('httpchk') }}
      {{ httpcheck('factory-dashboard.opensuse.org', 200, '/check.txt', 'options') }}
      mode: http
      {{ server('community2', '2a07:de40:b27e:1203::129') }}
    conncheck:
      mode: http
      options: ['tcpka']
      httprequests: set-log-level silent
      extra:
        - errorfile 503 {{ errorfiles }}conncheck.txt.http
    dale:
      {{ options('httpchk') }}
      {{ httpcheck('events.opensuse.org', 200, '/robots.txt') }}
      {{ server('dale', '2a07:de40:b27e:1203::b16', 80) }}
    deadservices:
      options: ['tcpka']
      mode: http
      httprequests: set-log-level silent
      extra:
        - errorfile 503 {{ errorfiles }}deprecated.html.http
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
    forums:
      {{ options('httpchk') }}
      {{ httpcheck('forums.opensuse.org', 200, '/srv/status') }}
      {{ server('discourse01', '2a07:de40:b27e:1203::b47') }}
    gccstats:
      {{ options() }}
      {{ server('gccstats', '2a07:de40:b27e:1203::b45') }}
    hackweek:
      mode: http
      {{ options() }}
      {{ server('dale_hackweek', '2a07:de40:b27e:1203::b16', 81) }}
    internal:
      mode: http
      httprequests:
        - >-
          return status 511
          content-type text/html
          file {{ errorfiles }}internal.html
          hdr Cache no-cache
    ip:
      httprequests:
        - >-
          return status 200
          content-type application/json
          lf-file {{ errorfiles }}ip.html
    jekyll:
      {{ options('httpchk') }}
      {{ httpcheck('search.opensuse.org', 200, method='options') }}
      {{ server('jekyll', '2a07:de40:b27e:1203::e1') }}
      acls:
        - is_jekyll_test          hdr_reg(host) -i (.*)-test\.opensuse\.org
      extra: http-request replace-header HOST (.*)-test(.*) \1\2 if is_jekyll_test
    kubic:
      {{ options ('httpchk') }}
      {{ httpcheck('kubic.opensuse.org', 200, '/check.txt') }}
      {{ server('kubic', '2a07:de40:b27e:1203::132') }}
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
    mailman3:
      {{ options('httpchk') }}
      {{ httpcheck('lists.opensuse.org', 200, '/archives/') }}
      {{ server('mailman3', '2a07:de40:b27e:1203::b46', extra_extra='inter 30s') }}
    matrix:
      {{ options() }}
      {{ server('matrix', '2a07:de40:b27e:1203::b40') }}
    metricsioo:
      {{ options() }}
      {{ server('metrics', '2a07:de40:b27e:1203::141', 3000) }}
    minio:
      {{ options() }}
      {{ server('minio', '2a07:de40:b27e:1203::c1') }}
    monitor:
      {{ options('httpchk') }}
      {{ httpcheck('monitor.opensuse.org', 200, '/check.txt') }}
      {{ server('monitor', '2a07:de40:b27e:1203::50', extra_extra='inter 30000') }}
    monitor_grafana:
      {{ options() }}
      {{ server('grafana', '2a07:de40:b27e:1203::50', 3000, extra_extra='inter 30000') }}
    nuka:
      {{ options('httpchk') }}
      {{ httpcheck('l10n.opensuse.org', 200, '/static/weblate-128.png') }}
      {{ server('nuka', '2a07:de40:b27e:1203::b44') }}
    obsreview:
      {{ options() }}
      {{ server('obsreview', '2a07:de40:b27e:1203::137') }}
    opi_proxy:
      mode: http
      {{ options() }}
      {{ server('opi_proxy', '2a07:de40:b27e:1203::134', extra_extra='inter 5000') }}
    osc_collab:
      mode: http
      {{ options('httpchk') }}
      {{ httpcheck('osc-collab.opensuse.org', 200, '/check.txt', 'options') }}
      {{ server('osc_collab2', '2a07:de40:b27e:1203::131') }}
    pagure:
      mode: http
      {{ options() }}
      {{ server('pagure', '2a07:de40:b27e:1206::a', extra_extra='inter 5000') }}
    paste:
      {{ options() }}
      {{ server('paste', '2a07:de40:b27e:1203::c2') }}
    pinot:
      {{ options() }}
      {{ server('pinot', '2a07:de40:b27e:1203::b15') }}
    redirect_www_o_o:
      redirects: code 302 location https://www.opensuse.org/
    redmine:
      {{ options('httpchk') }}
      {{ httpcheck('progress.opensuse.org', 200) }}
      {{ server('progressoo', '2a07:de40:b27e:1203::b17', 3001, extra_extra='maxconn 16') }}
    riesling:
      {{ options() }}
      {{ server('riesling', '2a07:de40:b27e:1203::b2') }}
    rpmlint:
      {{ options() }}
      {{ server('rpmlint', '2a07:de40:b27e:1203::136', extra_extra='inter 5000') }}
    staticpages:
      {{ options('httpchk') }}
      {{ httpcheck('static.opensuse.org', 200, method='options') }}
      balance: roundrobin
      mode: http
      servers:
        {%- for static_server, address in narwals.items() %}
        {{ server(static_server, address, 80, header=False) }}
        {%- endfor %}
    svn:
      {{ options() }}
      {{ server('svn', '2a07:de40:b27e:1203::133') }}
    tsp:
      {{ options() }}
      {{ server('tsp', '2a07:de40:b27e:1203::b20') }}
    www_openid_ldap:
      {{ options() }}
      {{ server('ldap-proxy', 'id.opensuse.org', 443, extra_extra='ssl verify required ca-file /etc/ssl/ca-bundle.pem') }}
      mode: http

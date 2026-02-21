{%- from 'common/haproxy/map.jinja' import errorfiles, narwals, options, server, httpcheck %}

haproxy:
  backends:
    berghain_http_challenge_front:
      mode: http
      acls:
        - legacy_browser hdr_reg(User-Agent) '^Mozilla/5\.0 \(X11; Linux x86_64; rv:[\d\.]+\) Gecko/\d+ (Firefox/\d{3,4}.\d )?SeaMonkey/2.\d\d.\d\d$'
      httprequests:
        {%- for acl, page in {
              'legacy_browser': 'native-crypto',
              '': 'default',
            }.items()
        %}
        - >-
            return status 403
            content-type text/html
            file /srv/www/berghain/{{ page }}/index.html
            hdr Cache no-cache
            hdr Server 'openSUSE is good for you'
            hdr X-Via {{ grains.host }}
            {% if acl %}if {{ acl }}{% endif %}
        {%- endfor %}
    berghain_http_challenge_back:
      mode: http
      acls:
        - is_challenge_path path /cdn-cgi/challenge-platform/challenge
        - has_token var(txn.berghain.token) -m found
      httprequests:
        - send-spoe-group berghain challenge if is_challenge_path
        - return status 501 if { var(txn.berghain.error) -m found }
        - return status 200 content-type application/json lf-string "%[var(txn.berghain.response)]" if is_challenge_path
        - return status 404
      # TODO: add "filter" and "http-after-response" support to formula template
      extra:
        - filter spoe engine berghain config /etc/haproxy/berghain-spoe.cfg  # SPOE configuration is managed by the berghain-spoe-haproxy package
        - filter compression
        - http-after-response add-header set-cookie "berghain=%[var(txn.berghain.token)]; %[var(txn.berghain.domain)] path=/;" if has_token
    berghain_spop:
      mode: tcp
      options: spop-check
      servers:
        localhost:
          host: unix@/run/berghain/spop.sock
          check: check
      extra:
        - fullconn 10000
    calendar:
      {{ options('httpchk') }}
      {{ httpcheck('calendar.opensuse.org', 200, '/up') }}
      {{ server('calendar', '2a07:de40:b27e:1203::b51') }}
    code-dev:
      {{ options('httpchk') }}
      {{ httpcheck('code-dev.opensuse.org', 200, '/api/healthz', 'get', tls=True) }}
      {{ server('code-dev', '2a07:de40:b27e:1219::a', 3000, extra_extra='ssl verify required ca-file /usr/share/pki/trust/anchors/stepca-opensuse-ca.crt.pem') }}
    community: {#- community points to httpd on community2 #}
      {{ options ('httpchk') }}
      {{ httpcheck('community.opensuse.org', 200, method='options') }}
      {{ server('community', '2a07:de40:b27e:1203::129', 8080) }}
    community2: {#- community2 points to nginx on community2 #}
      {{ options('httpchk') }}
      {{ httpcheck('factory-dashboard.opensuse.org', 200, '/check.txt', 'options') }}
      mode: http
      {{ server('community2', '2a07:de40:b27e:1203::129') }}
    dale:
      {{ options('httpchk') }}
      {{ httpcheck('events.opensuse.org', 200, '/robots.txt') }}
      {{ server('dale', '2a07:de40:b27e:1203::b16', 80) }}
    deadservices:
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
          content-type text/plain
          lf-file {{ errorfiles }}ip.html
    jekyll:
      {{ options('httpchk') }}
      {{ httpcheck('search.opensuse.org', 200, method='options') }}
      {{ server('jekyll', '2a07:de40:b27e:1203::e1') }}
    kubic:
      {{ options ('httpchk') }}
      {{ httpcheck('kubic.opensuse.org', 200, '/check.txt') }}
      {{ server('kubic', '2a07:de40:b27e:1203::132') }}
    kudos_prod:
      {{ options ('httpchk') }}
      {{ httpcheck('kudos.opensuse.org', 200, '/api/health', tls='http/1.1') }}
      {{ server('kudos-prod', 'kudos-prod.infra.opensuse.org', 3000, extra_extra='ssl verify required ca-file /usr/share/pki/trust/anchors/stepca-opensuse-ca.crt.pem') }}
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
      {{ options('httpchk') }}
      {{ httpcheck('paste.opensuse.org', 200, '/up') }}
      {{ server('paste', '2a07:de40:b27e:1203::c2') }}
    pinot:
      {{ options() }}
      {{ server('pinot', '2a07:de40:b27e:1203::b15') }}
    quiz:
      {{ options('httpchk') }}
      {{ httpcheck('quiz.infra.opensuse.org', 200, '/check', tls=True) }}
      {{ server('quiz', '2a07:de40:b27e:1218::a10', 443, extra_extra='ssl verify required ca-file /usr/share/pki/trust/anchors/stepca-opensuse-ca.crt.pem') }}
      httprequests:
        - set-header X-Forwarded-Host %[req.hdr(Host)]
    redirect_www_o_o:
      redirects: code 302 location https://www.opensuse.org/
    redmine:
      {{ options('httpchk') }}
      {{ httpcheck('progress.opensuse.org', 200) }}
      {{ server('progressoo', '2a07:de40:b27e:1203::b17', 3001, extra_extra='maxconn 16') }}
      # TODO: add "httpresponses" backend support to formula template
      extra:
        - >-
            http-response set-header
            Cache-Control max-age=604800,\ immutable
            if { capture.req.uri -m reg ^/assets/.*-[0-9a-f]{8}\.(css|eot|gif|ico|js|json|otf|png|svg|ttf|txt|woff2?)$ }
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
    tsp:
      {{ options('httpchk') }}
      {{ httpcheck('tsp.opensuse.org', 301) }}
      {{ server('tsp', '2a07:de40:b27e:1203::b20', extra_check='inter 5s') }}
    www_openid_ldap:
      {{ options() }}
      {{ server('ldap-proxy', 'id.opensuse.org', 443, extra_extra='ssl verify required ca-file /etc/ssl/ca-bundle.pem') }}
      mode: http
    {%- for subdomain in [
          'code',
          'lists',
        ]
    %}
    {{ subdomain }}_robots_txt:
      mode: http
      httprequests:
        - set-log-level silent
        - >-
          return status 200
          content-type text/plain
          file /etc/haproxy/robots/{{ subdomain }}_o_o
          hdr Server 'openSUSE'
    {%- endfor %}


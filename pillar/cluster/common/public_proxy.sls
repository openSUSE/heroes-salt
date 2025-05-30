{%- from 'common/haproxy/map.jinja' import errorfiles %}
{%- import_yaml 'common/haproxy/goodbots.yaml' as goodbots %}

haproxy:
  global:
    extra:
      - lua-load-per-thread /etc/haproxy/geoip.lua
  frontends:
    http:
      acls:
        - speedy_300 sc0_conn_rate(http) gt 300

        - annoying_networks   src                  -f /etc/haproxy/blacklists/networks -n    # salt/profile/proxy/files/etc/haproxy/blacklists/networks
        - annoying_useragents hdr_sub(User-Agent)  -i -f /etc/haproxy/blacklists/useragents  # salt/profile/proxy/files/etc/haproxy/blacklists/useragents
        - is_ssl              dst_port    443

        - method_get          method      GET

        {%- for bot in goodbots %}
        - bot_{{ bot['name'] }}_network   {{ ' ' * ( 16 - bot['name'] | length ) }} src -f /etc/haproxy/allowlists/networks/{{ bot['name'] }} -n  # generated from pillar/common/haproxy/goodbots.yaml
          {%- if 'user_agent_regex' in bot %}
        - bot_{{ bot['name'] }}_useragent {{ ' ' * ( 16 - bot['name'] | length ) }} hdr_reg(User-Agent) {{ bot['user_agent_regex'] }}
          {%- endif %}
        {%- endfor %}

        - good_crawler        var(req.is_good_crawler) -m bool
      options:
        - http-server-close
      tcprequests:
        - content set-var(sess.country) src,lua.geoip2-lookup-city("country")
      httprequests:
        - del-header:
          - X-Forwarded-For
          - ^X-Forwarded-(Proto|Ssl).*
          - ^HTTPS.*
        - add-header:
          - HTTPS on if is_ssl
          - X-Forwarded-Ssl on if is_ssl
          - X-Forwarded-Proto https if is_ssl
          - X-Forwarded-Protocol https if is_ssl
          - X-Forwarded-Proto http unless is_ssl
          - X-Forwarded-Protocol http unless is_ssl
        - deny:
          - deny_status 403 if annoying_useragents
        - set-var(txn.host): hdr(Host)
        {%- for bot in goodbots %}
        - set-var(req.is_good_crawler): bool(true) if bot_{{ bot['name'] }}_network {% if 'user_agent_regex' in bot %} bot_{{ bot['name'] }}_useragent {% endif %}
        {%- endfor %}
        - track-sc0: src
      httpresponses:
        - del-header:
          - X-Powered-By
          - Server
        - set-header:
          - X-XSS-Protection "1; mode=block" if is_ssl
          - X-Content-Type-Options nosniff if is_ssl
          - Referrer-Policy no-referrer-when-downgrade if is_ssl
          - Strict-Transport-Security max-age=15768000
      sticktable: type ipv6 size 500k expire 1m store conn_rate(10s),http_req_rate(30s)
  backends:
    conncheck:
      mode: http
      httprequests: set-log-level silent
      extra:
        - errorfile 503 {{ errorfiles }}conncheck.txt.http
    matrix-client:
      mode: http
      httprequests:
        - set-log-level silent
        - >-
          return status 200
          content-type application/json
          file /etc/haproxy/errorfiles/matrix-client.response
          hdr Server 'openSUSE is good for you'
          hdr Access-Control-Allow-Origin '*'
          hdr Cache no-cache
    matrix-federation:
      mode: http
      httprequests:
        - set-log-level silent
        - >-
          return status 200
          content-type application/json
          file /etc/haproxy/errorfiles/matrix-federation.response
          hdr Server 'openSUSE is good for you'
          hdr Access-Control-Allow-Origin '*'
          hdr Cache no-cache

profile:
  proxy:
    berghain:
      frontend:
        # frontend names match HAProxy frontend names
        http:
          # list order matters, each entry is one "level" to target in HAProxy ACLs, starting from 1
          levels:
            - countdown: 1
              duration: 24h
              type: pow
          trusted_domains:
            - opensuse.org
    haproxy:
      geoip: true
      goodbots: {{ goodbots }}

zypper:
  packages:
    lua53-haproxy-geoip2: {}

{%- from slspath ~ '/map.jinja' import bind, extra, options, server, errorfiles, narwals, galeras, check_txt -%}

include:
  - common.haproxy
  - .backends
  - .services_http_ext
  - .services_http_int

haproxy:
  listens:
    ssl-ext:
      bind:
        {%- set bindopts = 'tfo alpn h2,http/1.1 npn h2,http/1.1 ssl crt /etc/ssl/services/' %}
        {{ bind(['195.135.221.145', '195.135.221.139', '62.146.92.205', '195.135.221.140', '195.135.221.143'], 443, bindopts) }}
        {{ bind(['2a01:138:a004::205', '2001:67C:2178:8::16', '2620:113:80c0:8::16', '2001:67C:2178:8::18', '2620:113:80c0:8::18'], 443, 'v6only ' ~ bindopts) }}
      options:
        - tcp-smart-connect
      {{ server('http-ext-in', '127.0.0.1', 82, check=None, extra_extra='send-proxy-v2') }}
    ssl-int:
      bind:
        {%- set bindopts = 'tfo ssl alpn h2,http/1.1 npn h2,http/1.1 crt /etc/ssl/services/star_opensuse_org_letsencrypt_fullchain_key_dh.pem' %}
        {{ bind(['192.168.47.4', '192.168.87.5'], 443, bindopts) }}
      options:
        - tcp-smart-connect
      {{ server('http-int-in', '127.0.0.1', 83, check=None, extra_extra='send-proxy-v2') }}
    {%- for galera_block, galera_port in {'galera': 3307, 'galera-slave': 3308}.items() %}
    {{ galera_block }}:
      bind:
        {{ bind(['192.168.47.4'], galera_port) }}
      mode: tcp
      balance: source
      options:
        - tcplog
        - tcpka
        - httpchk GET / HTTP/1.1\r\nHost:\ localhost:8000\r\nUser-Agent:\ haproxy/galera-clustercheck\r\nAccept:\ */*
      timeouts:
        - connect 10s
        - client 30m
        - server 30m
      servers:
        {%- for host, append in galeras[galera_block].items() %}
        {{ host }}:
          host: {{ host }}.infra.opensuse.org
          port: 3306
          check: check
          extra: port 8000 inter 3000 rise 3 fall 3 {{ append }}
        {%- endfor %}
    {%- endfor %}
    rsync-community2:
      bind:
        {{ bind(['195.135.221.140', '2620:113:80c0:8::16'], 11873) }}
      mode: tcp
      options:
        - tcplog
        - tcpka
      servers:
        rsync_community2:
          host: 192.168.47.79
          port: 873
    kernel-git-in:
      bind:
        {{ bind(['195.135.221.140', '2620:113:80c0:8::16'], 9418) }}
      mode: tcp
      options:
        - tcplog
      servers:
        kernel-git:
          host: 192.168.47.25
          port: 9418
  frontends:
    http-ext-in:
      bind:
        {%- set bindopts = 'tfo' %}
        {%- set bindopts_proxy = bindopts ~ ' accept-proxy' %}
        {%- set bindopts_v6 = bindopts ~ ' v6only' %}
        {{ bind(['127.0.0.1', '62.146.92.205', '195.135.221.139', '195.135.221.140', '195.135.221.143', '195.135.221.145'], 80, bindopts) }}
        {{ bind(['127.0.0.1'], 82, bindopts_proxy) }}
        {{ bind(['192.168.47.101', '192.168.47.102'], 443, bindopts_proxy) }}
        {{ bind(['2a01:138:a004::205', '2001:67C:2178:8::16', '2620:113:80c0:8::16', '2001:67C:2178:8::18', '2620:113:80c0:8::18'], 80, bindopts_v6) }}
      options:
        - http-server-close
      extra:
        {{ extra({
              'http-request': {
                'del-header': [
                  'X-Forwarded-For', '^X-Forwarded-(Proto|Ssl).*', '^HTTPS.*'
                ],
                'add-header': [
                  'HTTPS on if is_ssl', 'X-Forwarded-Ssl on if is_ssl', 'X-Forwarded-Proto https if is_ssl !is_www',
                  'X-Forwarded-Protocol https if is_ssl', 'X-Forwarded-Proto http unless is_ssl', 'X-Forwarded-Protocol http unless is_ssl'
                ],
                'deny': [
                  'if { fc_http_major 1 } !{ req.body_size 0 } !{ req.hdr(content-length) -m found } !{ req.hdr(transfer-encoding) -m found } !{ method CONNECT }'
                ] },
              'http-response': {
                'del-header': [
                  'X-Powered-By', 'Server'
                ],
                'set-header': [
                  'X-Frame-Options SAMEORIGIN if is_ssl !no_x-frame-option', 'X-XSS-Protection "1; mode=block" if is_ssl', 'X-Content-Type-Options nosniff if is_ssl',
                  'Referrer-Policy no-referrer-when-downgrade if is_ssl', 'Strict-Transport-Security max-age=15768000'
                ] }
        }) }}
        - http-request set-var(txn.host) hdr(Host)
    http-int-in:
      bind:
        {{ bind(['127.0.0.1'], 83, bindopts_proxy) }}
        {{ bind(['192.168.47.4', '192.168.87.5'], 80, bindopts) }}
      options:
        - http-server-close
      extra:
        {{ extra({
              'http-request': {
                'del-header': [
                  'X-Forwarded-For', '^X-Forwarded-(Proto|Ssl).*', '^HTTPS.*'
                ],
                'add-header': [
                  'HTTPS on if is_ssl', 'X-Forwarded-Ssl on if is_ssl', 'X-Forwarded-Proto https if is_ssl', 'X-Forwarded-Protocol https if is_ssl',
                  'X-Forwarded-Proto http unless is_ssl', 'X-Forwarded-Protocol http unless is_ssl'
                ] },
              'http-response': {
                'add-header': [
                  'Strict-Transport-Security max-age=31536000;includeSubDomains;preload if is_ssl'
                ] }
        }) }}
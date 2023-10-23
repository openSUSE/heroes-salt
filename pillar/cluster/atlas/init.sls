{%- from 'common/haproxy/map.jinja' import bind, extra, server %}

include:
  - common.haproxy
  - .backends
  - .services

haproxy:
  listens:
    tls:
      bind:
        {%- set bindopts = 'tfo alpn h2,http/1.1 npn h2,http/1.1 ssl crt /etc/ssl/services/' %}
        {{ bind(['2a07:de40:b27e:1204::10'], 443, 'v6only ' ~ bindopts) }}
        {{ bind(['172.16.130.10'], 443, bindopts) }}
      options:
        - tcp-smart-connect
  frontends:
    http:
      bind:
        {%- set bindopts = 'tfo' %}
        {{ bind(['2a07:de40:b27e:1203::e8'], 80, 'v6only ' ~ bindopts) }}
        {{ bind(['172.16.130.10'], 80, bindopts) }}
      options:
        - http-server-close
      extra:
        {{ extra({
              'http-request': {
                'del-header': [
                  'X-Forwarded-For', '^X-Forwarded-(Proto|Ssl).*', '^HTTPS.*'
                ],
                'add-header': [
                  'HTTPS on if is_ssl', 'X-Forwarded-Ssl on if is_ssl', 'X-Forwarded-Proto https if is_ssl',
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
                  'X-XSS-Protection "1; mode=block" if is_ssl', 'X-Content-Type-Options nosniff if is_ssl',
                  'Referrer-Policy no-referrer-when-downgrade if is_ssl', 'Strict-Transport-Security max-age=15768000'
                ] }
        }) }}
        - http-request set-var(txn.host) hdr(Host)


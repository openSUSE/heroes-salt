{%- from 'common/haproxy/map.jinja' import bind, extra, server %}

include:
  - common.haproxy
  - .backends
  - .services
  - .vrrp
  {%- if salt['grains.get']('include_secrets', True) %}
  - secrets.cluster.atlas
  {%- endif %}

{%- set bind_v6_vip = ['2a07:de40:b27e:1204::10'] %}
{%- set bind_v6 = bind_v6_vip + ['2a07:de40:b27e:1204::11', '2a07:de40:b27e:1204::12'] %}
{%- set bind_v4_vip = ['172.16.130.10'] %}
{%- set bind_v4 = bind_v4_vip + ['172.16.130.11', '172.16.130.12'] %}

{%- set bind_v6_vip2 = ['2a07:de40:b27e:1204::13'] %}
{%- set bind_v4_vip2 = ['172.16.130.13'] %}

haproxy:
  frontends:
    http:
      bind:
        {%- set bindopts = 'tfo' %}
        {{ bind(bind_v6, 80, 'v6only ' ~ bindopts) }}
        {{ bind(bind_v4, 80, bindopts) }}
        {%- set tls_bindopts = 'tfo alpn h2,http/1.1 npn h2,http/1.1 ssl crt /etc/ssl/services/' %}
        {{ bind(bind_v6, 443, 'v6only ' ~ tls_bindopts) }}
        {{ bind(bind_v4, 443, tls_bindopts) }}
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

    http-misc:
      bind:
        {{ bind(bind_v6_vip2, 80, 'v6only ' ~ bindopts) }}
        {{ bind(bind_v4_vip2, 80, bindopts) }}
        {{ bind(bind_v6_vip2, 443, 'v6only ' ~ tls_bindopts) }}
        {{ bind(bind_v4_vip2, 443, tls_bindopts) }}
      options:
        - http-server-close
      extra:
        - http-request set-var(txn.host) hdr(Host)

  listens:
    rsync-community2:
      acls: network_allowed src 195.135.223.25/32 # botmaster; additionaly restricted in border firewall
      bind:
        {{ bind(bind_v4_vip, 11873, bindopts) }}
      mode: tcp
      options:
        - tcplog
        - tcpka
      servers:
        rsync_community2:
          host: 2a07:de40:b27e:1203::129
          port: 873

    ssh-pagure01:
      bind:
        {{ bind(bind_v6_vip2, 22, 'v6only ' ~ bindopts) }}
        {{ bind(bind_v4_vip2, 22, bindopts) }}
      mode: tcp
      options:
        - tcplog
      servers:
        ssh_pagure01:
          host: 2a07:de40:b27e:1206::a
          port: 22

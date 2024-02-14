{%- from 'common/haproxy/map.jinja' import bind, extra, server, rsync_backend_with_checks %}
{%- set host = grains['host'] %}

{%- if host.startswith('runner-') %} {#- handle host based dictionaries in CI tests #}
{%- set host = 'atlas1' %}
{%- endif %}

include:
  - common.haproxy
  - cluster.common.public_proxy
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

{#- http-misc #}
{%- set bind_v6_vip2 = ['2a07:de40:b27e:1204::13'] %}
{%- set bind_v4_vip2 = ['172.16.130.13'] %}

{#- mx-test #}
{%- set bind_v6_vip3 = ['2a07:de40:b27e:1204::14'] %}
{%- set bind_v4_vip3 = ['172.16.130.14'] %}

{#- mx1, mx2 #}
{%- set bind_v6_mx = { 'atlas1': ['2a07:de40:b27e:1204::51'], 'atlas2': ['2a07:de40:b27e:1204::52'] } %}
{%- set bind_v4_mx = { 'atlas1': ['172.16.130.51'], 'atlas2': ['172.16.130.52'] } %}

{#- atlas-login, atlas-login1, atlas-login2 #}
{%- set bind_v6_login_vip = ['2a07:de40:b27e:1204::7'] %}
{%- set bind_v6_login = { 'atlas1': bind_v6_login_vip + ['2a07:de40:b27e:1204::8'], 'atlas2': bind_v6_login_vip + ['2a07:de40:b27e:1204::9'] } %}

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
      httprequests:
        - track-sc0: src
        - deny:
          - deny_status 429 if annoying_clients
          - if { fc_http_major 1 } !{ req.body_size 0 } !{ req.hdr(content-length) -m found } !{ req.hdr(transfer-encoding) -m found } !{ method CONNECT }
        - set-var(txn.host): hdr(Host)
      sticktable: type ipv6 size 500k expire 1m store http_req_rate(30s)

    http-login:
      bind:
        {{ bind(bind_v6_login[host], 443, 'v6only tfo alpn h2,http/1.1 npn h2,http/1.1 ssl crt /etc/ssl/services/') }}

    http-misc:
      bind:
        {{ bind(bind_v6_vip2, 80, 'v6only ' ~ bindopts) }}
        {{ bind(bind_v4_vip2, 80, bindopts) }}
        {{ bind(bind_v6_vip2, 443, 'v6only ' ~ tls_bindopts) }}
        {{ bind(bind_v4_vip2, 443, tls_bindopts) }}
      options:
        - http-server-close
      httprequests:
        - track-sc0: src
        - deny:
          - deny_status 429 if annoying_clients
        - set-var(txn.host): hdr(Host)
      sticktable: type ipv6 size 250k expire 1m store http_req_rate(30s)

  listens:
    rsync-community2:
      acls: network_allowed src 195.135.223.25/32 # botmaster; additionaly restricted in border firewall
      {{ rsync_backend_with_checks('2a07:de40:b27e:1203::129', listen_addresses=bind_v4_vip, listen_port=11873, listen_params=bindopts) }}

    rsync-man:
      acls: network_allowed src 10.151.132.20/32 10.151.132.21/32 10.151.132.22/32  # obs-gateway; additionaly restricted in firewall
      {{ rsync_backend_with_checks('2a07:de40:b27e:1203::130', listen_addresses=bind_v4_vip, listen_port=11874, listen_params=bindopts ~ ' ssl crt /etc/ssl/services/proxy-prg2.opensuse.org.pem') }}

    {%- for smtp_instance, smtp_config in {
          'smtp': {
            'bind4': bind_v4_mx[host],
            'bind6': bind_v6_mx[host],
            'backends': ['mx1', 'mx2']
          },
          'smtp-test': {
            'bind4': bind_v4_vip3,
            'bind6': bind_v6_vip3,
            'backends': ['mx-test']
          }
        }.items()
    %}
    {{ smtp_instance }}:
      bind:
        {{ bind(smtp_config['bind6'], 25, 'v6only') }}
        {{ bind(smtp_config['bind4'], 25) }}
      mode: tcp
      options:
        - tcplog
        - smtpchk EHLO smtp-check.atlas.infra.opensuse.org
      timeouts:
        - connect 5s
        - server 20s
      servers:
        {%- for mx in smtp_config['backends'] %}
        {{ mx }}:
          check: check inter 30s
          extra: send-proxy-v2
          host: {{ mx }}.infra.opensuse.org
          port: 25
        {%- endfor %}
    {%- endfor %}

    ssh-pagure01:
      bind:
        {{ bind(bind_v6_vip2, 22, 'v6only ' ~ bindopts) }}
        {{ bind(bind_v4_vip2, 22, bindopts) }}
      mode: tcp
      options:
        - tcplog
        - tcp-check
      tcpchecks: expect rstring SSH-2.0-OpenSSH_\d\.[\d\w]+
      servers:
        ssh_pagure01:
          check: check inter 10s
          host: 2a07:de40:b27e:1206::a
          port: 22

{%- from 'common/haproxy/map.jinja' import bind, metrics %}

include:
  - common.haproxy
  - cluster.common.public_proxy
  - .backends
  - .services
  - .vrrp

{%- set bind_v6_vip = ['2a07:de40:617e:1904::10'] %}
{%- set bind_v6_standalone = ['2a07:de40:617e:1904::11', '2a07:de40:617e:1904::12'] %}
{%- set bind_v6 = bind_v6_vip + bind_v6_standalone %}
{%- set bind_v4_vip = ['172.16.113.10'] %}
{%- set bind_v4 = bind_v4_vip + ['172.16.113.11', '172.16.113.12'] %}

haproxy:
  frontends:
    http:
      bind:
        {%- set bindopts = 'tfo' %}
        {%- set bindopts6 = 'v6only ' ~ bindopts %}
        {{ bind(bind_v6, 80, bindopts6) }}
        {{ bind(bind_v4, 80, bindopts) }}
        {%- set tls_bindopts = bindopts ~ ' alpn h2,http/1.1 npn h2,http/1.1 ssl crt /etc/ssl/services/' %}
        {{ bind(bind_v6, 443, 'v6only ' ~ tls_bindopts) }}
        {{ bind(bind_v4, 443, tls_bindopts) }}
      httprequests:
        - deny:
          - deny_status 429 if annoying_networks !host_conncheck !host_slc_mirror
          - deny_status 429 if { sc_http_req_rate(0) gt 300 } !host_slc_mirror
          - deny_status 429 if speedy_300 !host_slc_mirror
        - return:
          - status 404 if suffix_asp
          - status 404 if suffix_php

    rsync:
      bind:
        {{ bind(bind_v6_vip, 873, bindopts6) }}
        {{ bind(bind_v4_vip, 873, bindopts) }}
      mode: tcp
      options:
        - tcplog

  listens:
    {{ metrics(bind_v6_standalone) }}

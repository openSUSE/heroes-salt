{%- from 'common/haproxy/map.jinja' import bind %}

include:
  - common.haproxy
  - cluster.common.public_proxy
  - .backends
  - .services

{%- set bind_v6 = ['2a07:de40:401::65', '2a07:de40:401::66', '2a07:de40:401::67'] %}
{%- set bind_v4 = ['91.193.113.65', '91.193.113.66', '91.193.113.67'] %}

haproxy:
  frontends:
    http:
      bind:
        {%- set bindopts = 'tfo' %}
        {{ bind(bind_v6, 80, 'v6only ' ~ bindopts) }}
        {{ bind(bind_v4, 80, bindopts) }}
        {%- set tls_bindopts = bindopts ~ ' alpn h2,http/1.1 npn h2,http/1.1 ssl crt /etc/ssl/services/' %}
        {{ bind(bind_v6, 443, 'v6only ' ~ tls_bindopts) }}
        {{ bind(bind_v4, 443, tls_bindopts) }}


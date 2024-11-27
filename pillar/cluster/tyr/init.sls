{%- from 'common/haproxy/map.jinja' import bind, metrics %}

include:
  - common.haproxy
  - .dns
  - .vrrp
  {%- if salt['grains.get']('include_secrets', True) %}
  - secrets.cluster.tyr
  {%- endif %}

grains:
  configure_ntp: false

{%- set bind_v6_standalone = ['2a07:de40:617e:1903::11', '2a07:de40:617e:1903::12'] %}
{%- set bind_v6 = ['2a07:de40:617e:1903::10'] + bind_v6_standalone %}

haproxy:

  frontends:
    https:
      bind:
        {{ bind(bind_v6, 443, 'v6only tfo alpn h2,http/1.1 npn h2,http/1.1 ssl crt /etc/ssl/services/') }}
      acls: []
      use_backends: []

  backends: {}

  listens:
    {{ metrics(bind_v6_standalone) }}

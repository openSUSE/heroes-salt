{%- from 'common/haproxy/map.jinja' import bind, extra, server %}

include:
  - common.haproxy
  - .vrrp
  {%- if salt['grains.get']('include_secrets', True) %}
  - secrets.cluster.hel
  {%- endif %}

{%- set bind_v6 = ['2a07:de40:b27e:1203::10', '2a07:de40:b27e:1203::11', '2a07:de40:b27e:1203::12'] %}

haproxy:
  listens:
    stats:
      bind:
        {{ bind(bind_v6, 80, 'v6only tfo') }}
      stats:
        enable: true
        hide-version: ''
        uri: /
        refresh: 5s
        realm: Monitor
        auth: '"$STATS_USER":"$STATS_PASSPHRASE"'

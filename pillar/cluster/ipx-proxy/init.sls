{%- from 'common/haproxy/map.jinja' import bind, metrics %}

include:
  - common.haproxy

{%- set bind_v6 = ['2a01:138:a004::205'] %}
{%- set bind_v4 = ['62.146.92.205'] %}

haproxy:
  listens:
    {{ metrics(['192.168.87.5'], False) }}
    statusoo:
      bind:
        {%- set bindopts = 'tfo' %}
        {{ bind(bind_v6, 80, 'v6only ' ~ bindopts) }}
        {{ bind(bind_v4, 80, bindopts) }}
        {{ bind(bind_v6, 443, 'v6only ' ~ bindopts) }}
        {{ bind(bind_v4, 443, bindopts) }}
      mode: tcp
      options:
        - tcplog
      servers:
        status1:
          host: status1.infra.opensuse.org

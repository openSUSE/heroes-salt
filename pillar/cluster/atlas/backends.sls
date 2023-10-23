{%- from 'cluster/anna_elsa/map.jinja' import options, server %}

haproxy:
  backends:
    staticpages:
      {{ options('httpchk OPTIONS /check.txt HTTP/1.1\r\nHost:\ static.opensuse.org') }}
      balance: roundrobin
      mode: http
      servers:
        {{ server('narwal8', '2a07:de40:b27e:1203::e8', 80, header=False) }}

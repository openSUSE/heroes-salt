{%- from 'common/haproxy/map.jinja' import bind, extra, galeras, server, httpcheck %}

include:
  - common.haproxy
  - .dns
  - .vrrp
  {%- if salt['grains.get']('include_secrets', True) %}
  - secrets.cluster.hel
  {%- endif %}

grains:
  configure_ntp: false

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
    {%- for galera_block, galera_port in {'galera': 3307, 'galera-slave': 3308}.items() %}
    {{ galera_block }}:
      bind:
        {{ bind(bind_v6, galera_port, 'v6only') }}
      mode: tcp
      balance: source
      options:
        - tcplog
        - tcpka
        - httpchk
      {{ httpcheck('localhost:8000', 200, method='get') }}
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

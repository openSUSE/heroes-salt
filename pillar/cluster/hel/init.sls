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

  {#- frontend/backend sections are only used for HTTPS ; other protocols use "listens" #}
  frontends:
    https:
      bind:
        {{ bind(bind_v6, 443, 'v6only tfo alpn h2,http/1.1 npn h2,http/1.1 ssl crt /etc/ssl/services/') }}
      acls:
        - host_idm         hdr(host)    idm.infra.opensuse.org
      use_backends:
        - kanidm           if host_idm

  backends:
    kanidm:
      balance: source
      mode: http
      options:
        - httpchk
      {{ httpcheck('idm.infra.opensuse.org', 200, '/status', tls=True) }}
      servers:
        {%- for i in [1, 2] %}
        {{ server('kani' ~ i, 'kani' ~ i ~ '.infra.opensuse.org', 443,
                    extra_extra='ssl verify required ca-file /usr/share/pki/trust/anchors/stepca-opensuse-ca.crt.pem',
                    header=False
                  ) }}
        {%- endfor %}

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

    smtp:
      bind:
        {{ bind(bind_v6, 25, 'v6only') }}
      mode: tcp
      options:
        - tcplog
        - smtpchk EHLO smtp-check.hel.infra.opensuse.org
      timeouts:
        - connect 5s
        - server 20s
      servers:
        {%- for i in [1, 2] %}
        mx{{ i }}:
          check: check inter 30s
          extra: send-proxy-v2
          host: mx{{ i }}.infra.opensuse.org
          port: 26
        {%- endfor %}

    ldaps:
      balance: source
      bind:
        {{ bind(bind_v6, 636, 'v6only tfo ssl crt /etc/ssl/services/idm.infra.opensuse.org.pem') }}
      mode: tcp
      options:
        - tcplog
        - tcp-check
      tcpchecks: connect port 636 ssl
      servers:
        {%- for i in [1, 2] %}
        kani{{ i }}:
          check: check inter 10s check-ssl
          host: kani{{ i }}.infra.opensuse.org
          port: 636
          extra: ssl verify required ca-file /usr/share/pki/trust/anchors/stepca-opensuse-ca.crt.pem
        {%- endfor %}

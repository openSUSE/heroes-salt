{%- from 'common/haproxy/map.jinja' import bind, errorfiles, extra, server, rsync_backend_with_checks, metrics, peers %}
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
{%- set bind_v6_map = {'atlas1': '2a07:de40:b27e:1204::11', 'atlas2': '2a07:de40:b27e:1204::12'} %}
{%- set bind_v6_standalone = bind_v6_map.values() | list %}
{%- set bind_v6 = bind_v6_vip + bind_v6_standalone %}
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
      tcprequests:
        - inspect-delay 5s
        - content:
          - accept if src_suse_office

          - accept unless host_lnt speedy_35
          - accept unless host_redmine cookie_ipsilon_username_missing path_redmine_gantt
          - accept unless host_redmine cookie_ipsilon_username_missing path_redmine_gantt_pdf
          - accept unless host_redmine cookie_ipsilon_username_missing path_redmine_gantt_png
          - accept if WAIT_END
      httprequests:
        - deny:
          - deny_status 429 if annoying_networks !host_conncheck
          # https://progress.opensuse.org/issues/181934
          - deny_status 403 errorfile /etc/haproxy/errorfiles/403.html.http if host_redmine path_redmine_gantt
          - deny_status 403 errorfile /etc/haproxy/errorfiles/403.html.http if host_redmine path_redmine_gantt_png
          - deny_status 403 errorfile {{ errorfiles }}403.html.http if host_redmine cookie_ipsilon_username_missing path_redmine_git difficult_country
          - deny_status 403 errorfile {{ errorfiles }}403.html.http if host_redmine cookie_ipsilon_username_missing path_redmine_gantt_pdf difficult_country
          - deny_status 429 if { sc_http_req_rate(0) gt 60 } host_lnt path_lnt_graph
          - deny_status 429 if { sc_http_req_rate(0) gt 80 } host_lnt
          - deny_status 429 if { sc_http_req_rate(0) gt 140 } host_mailman3
          - deny_status 429 if { sc_http_req_rate(0) gt 80 } host_redmine cookie_ipsilon_username_missing path_redmine_git !berghain_valid
          - deny_status 429 if { sc_http_req_rate(0) gt 80 } host_redmine cookie_ipsilon_username_missing path_redmine_gantt_pdf !berghain_valid
          - deny_status 429 if { sc_http_req_rate(0) gt 140 } host_redmine !src_suse_office
          - deny_status 429 if { sc_http_req_rate(0) gt 160 } host_redmine
          - deny_status 429 if { sc_http_req_rate(0) gt 300 } !src_limit_exclude !host_static_o_o
          - deny_status 429 if { sc_http_req_rate(0) gt 600 } !src_limit_exclude
          - deny_status 429 if speedy_300 !src_limit_exclude
        - return:
          - status 404 if suffix_asp
          - status 404 if suffix_env
          - status 404 if suffix_php !host_beans !host_limesurvey !host_pmya
        - set-var(req.berghain.level): int(1)  # TODO: multiple levels
        - send-spoe-group: berghain validate if !berghain_path berghain_active
        - wait-for-body: time 5s if berghain_path METH_POST
      sticktable: type ipv6 size 500k expire 1m store conn_rate(10s),http_req_rate(30s) peers atlas
      extra:
        - filter spoe engine berghain config /etc/haproxy/berghain-spoe.cfg  # SPOE configuration is managed by the berghain-spoe-haproxy package
        - filter compression

    http-login:
      bind:
        {{ bind(bind_v6_login[host], 443, 'v6only tfo alpn h2,http/1.1 npn h2,http/1.1 ssl crt /etc/ssl/services/') }}
      tcprequests:
        - inspect-delay 5s
        - content:
          - accept unless !cookie_os_session path_indexphp param_mw_days_from param_mw_hide !param_mw_limit
          - accept unless !cookie_os_session path_indexphp param_mw_days_from param_mw_hide param_mw_high_limit
          - accept if WAIT_END
      httprequests:
        - set-var(req.is_src_login): bool(true) if src_login_pre
        - set-src: req.hdr_ip(X-Forwarded-For,-1)
        - track-sc0: src
        - deny:
          - deny_status 403 if annoying_useragents
          - deny_status 429 if annoying_networks
          - deny_status 403 errorfile {{ errorfiles }}403.html.http if !cookie_os_session path_indexphp param_mw_days_from param_mw_hide !param_mw_limit
          - deny_status 403 errorfile {{ errorfiles }}403.html.http if !cookie_os_session path_indexphp param_mw_days_from param_mw_hide param_mw_high_limit
          - deny_status 429 if { sc_http_req_rate(0) gt 80 } path_indexphp
          - deny_status 429 if { sc_http_req_rate(0) gt 120 } host_mediawiki
          - deny_status 429 if { sc_http_req_rate(0) gt 300 }
        - return:
          - status 404 if suffix_asp
          - status 404 if suffix_php !host_mediawiki
          - status 406 if odd_clients host_mediawiki path_indexphp
      sticktable: type ipv6 size 50k expire 1m store conn_rate(10s),http_req_rate(30s) peers atlas

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
          - deny_status 403 if annoying_useragents
          - deny_status 429 if annoying_networks
        - set-var(txn.host): hdr(Host)
      sticktable: type ipv6 size 250k expire 1m store conn_rate(10s),http_req_rate(30s) peers atlas

  listens:
    {{ metrics(bind_v6_standalone) }}

    rsync-community2:
      acls: network_allowed src 195.135.223.25/32 # botmaster; additionaly restricted in border firewall
      {{ rsync_backend_with_checks('2a07:de40:b27e:1203::129', extra='send-proxy', listen_addresses=bind_v4_vip, listen_port=11873, listen_params=bindopts) }}

    rsync-man:
      acls: network_allowed src 10.151.132.20/32 10.151.132.21/32 10.151.132.22/32  # obs-gateway; additionaly restricted in firewall
      timeouts:
        - connect 5s
        - client 120m
        - server 120m
      {{ rsync_backend_with_checks('2a07:de40:b27e:1203::130', extra='send-proxy', listen_addresses=bind_v4_vip, listen_port=11874, listen_params=bindopts ~ ' ssl crt /etc/ssl/services/proxy-prg2.opensuse.org.pem') }}

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
      tcpchecks:
        - expect rstring SSH-2.0-OpenSSH_\d\.[\d\w]+
        - send SSH-2.0-HAProxy-Check\n
        - expect rstring openssh\.com
      servers:
        ssh_pagure01:
          check: check inter 30s
          extra: send-proxy-v2
          host: 2a07:de40:b27e:1206::a
          port: 2222

  {{ peers('atlas', host, bind_v6_map) }}

profile:
  proxy:
    berghain:
      enable: true

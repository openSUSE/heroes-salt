{%- from slspath ~ '/map.jinja' import bind, extra, options, server, redirects, narwals, check_txt -%}

include:
  - common.haproxy

haproxy:
  listens:
    ssl-ext:
      bind:
        {%- set bindopts = 'tfo ssl alpn h2,http/1.1 npn h2,http/1.1 ssl crt /etc/ssl/services/' %}
        {{ bind(['195.135.221.145', '195.135.221.139', '62.146.92.205', '195.135.221.140', '195.135.221.143'], 443, bindopts) }}
        {{ bind(['2a01:138:a004::205', '2001:67C:2178:8::16', '2620:113:80c0:8::16', '2001:67C:2178:8::18', '2620:113:80c0:8::18'], 443, 'v6only ' ~ bindopts) }}
      option: tcp-smart-connect
      server: 'http-ext-in 127.0.0.1:82 send-proxy-v2'
    ssl-int:
      bind:
        {%- set bindopts = 'tfo ssl alpn h2,http/1.1 npn h2,http/1.1 crt /etc/ssl/services/star_opensuse_org_letsencrypt_fullchain_key_dh.pem' %}
        {{ bind(['192.168.47.4', '192.168.87.5'], 443, bindopts) }}
      option: tcp-smart-connect
      server: 'http-int-in 127.0.0.1:83 send-proxy-v2'
    {%- for galera_block, galera_port in {'galera': 3307, 'galera-slave': 3308}.items() %}
    {{ galera_block }}:
      bind:
        {{ bind(['192.168.47.4'], galera_port) }}
      mode: tcp
      options:
        - tcplog
        - tcpka
        - httpchk GET / HTTP/1.1\r\nHost:\ localhost:8000\r\nUser-Agent:\ haproxy/galera-clustercheck\r\nAccept:\ */*
      timeouts:
        - connect 10s
        - client 30m
        - server 30m
      servers:
        {%- for host, append in {'galera1': 'weight 100', 'galera2': 'weight 90 backup', 'galera3': 'weight 80 backup'}.items() %}
        {{ host }}:
          host: {{ host }}.infra.opensuse.org
          port: 3306
          check: check
          extra: port 8000 inter 3000 rise 3 fall 3 {{ append }}
        {%- endfor %}
    {%- endfor %}
    rsync-community2:
      bind:
        {{ bind(['195.135.221.140', '2620:113:80c0:8::16'], 11873) }}
      mode: tcp
      options:
        - tcplog
        - tcpka
      servers:
        rsync_community2:
          host: 192.168.47.79
          port: 873
    kernel-git-in:
      bind:
        {{ bind(['195.135.221.140', '2620:113:80c0:8::16'], 9418) }}
      mode: tcp
      options:
        - tcplog
      servers:
        kernel-git:
          host: 192.168.47.25
          port: 9418
  frontends:
    http-ext-in:
      bind:
        {%- set bindopts = 'tfo' %}
        {%- set bindopts_proxy = bindopts ~ ' accept-proxy' %}
        {%- set bindopts_v6 = bindopts ~ ' v6only' %}
        {{ bind(['127.0.0.1', '195.135.221.145', '62.146.92.205', '195.135.221.140', '195.135.221.143'], 80, bindopts) }}
        {{ bind(['127.0.0.1'], 82, bindopts_proxy) }}
        {{ bind(['192.168.47.101', '192.168.47.102'], 443, bindopts_proxy) }}
        {{ bind(['2a01:138:a004::205', '2001:67C:2178:8::16', '2620:113:80c0:8::16', '2001:67C:2178:8::18', '2620:113:80c0:8::18'], 443, bindopts_v6) }}
      acls:
        - no_x-frame-option var(txn.host) -m str etherpad.opensuse.org
        - no_x-frame-option var(txn.host) -m str meet.opensuse.org
        - no_x-frame-option var(txn.host) -m str chat.opensuse.org
        - no_x-frame-option var(txn.host) -m str dimension.opensuse.org
        - no_x-frame-option var(txn.host) -m str metrics.opensuse.org
        - is_ssl                 fc_rcvd_proxy
        - is_dot_scm             path_beg      /.git/
        - is_dot_scm             path_beg      /.svn/
        - is_dot_scm             path_beg      /.bzr/
        - is_security            path_end      /.well-known/security.txt
        - is_relnotes            path_beg      /release-notes/
        - is_grafana             path_beg      /grafana/
        - is_kubic_registry      path_beg      /v2/
        - is_slash_openid        path_beg      -i /openid
        - is_slash_openid        path_beg      -i /common/app/
        - is_slash_openidlegacy  path_beg      -i /openidlegacy
        - is_slash_openid_ldap   path_beg      -i /openid-ldap
        - is_slash_openid_ldap   path_beg      -i /idp
        - is_slash_searchpage    path_beg      -i /searchPage
        - is_mailman3_uri        path_beg      -i /accounts/
        - is_mailman3_uri        path_beg      -i /manage/
        - is_mailman3_uri        path_beg      -i /archives/
        - is_mailman3_uri        path_beg      -i /static/
        - is_mailman3_uri        path_beg      -i /user-profile/
        - is_mailman3_uri        path_beg      -i /admin/
        - is_mailman3_uri        path_beg      -i /opensuse-test/
        - is_slash               path          /
        - is_favicon             path          /favicon.ico
        - is_www                 hdr(host)     -i www.opensuse.org
        - is_apparmor            hdr(host)     -i apparmor.opensuse.org
        - is_bugzilla_devel      hdr(host)     -i bugzilla-devel.opensuse.org
        - is_bugs                hdr(host)     -i bugs.opensuse.org
        - is_community2          hdr(host)     -i factory-dashboard.opensuse.org
        - is_redirect_events     hdr(host)     -i summit.opensuse.org
        - is_redirect_events     hdr(host)     -i conference.opensuse.org
        - is_redirect_events     hdr(host)     -i party.opensuse.org
        - is_redirect_events     hdr(host)     -i events-test.opensuse.org
        - is_tube                hdr(host)     -i tube.opensuse.org
        - is_jenkins             hdr(host)     -i ci.opensuse.org
        - is_community           hdr(host)     -i community.opensuse.org
        - is_counter             hdr_reg(host) -i count(er|down)\.opensuse\.org
        - is_contribute          hdr(host)     -i contribute.opensuse.org
        - is_doc                 hdr(host)     -i doc.opensuse.org
        - is_education           hdr(host)     -i education.opensuse.org
        - is_users               hdr(host)     -i users.opensuse.org
        - is_pmya                hdr(host)     -i pmya.opensuse.org
        - is_conncheck           hdr(host)     -i conncheck.opensuse.org
        - is_redirect_doc        hdr_reg(host) -i (docs|activedoc|www\.activedoc|rtfm).opensuse.org
        - is_etherpad            hdr(host)     -i etherpad.opensuse.org
        - is_features            hdr(host)     -i fate.opensuse.org
        - is_features            hdr(host)     -i features.opensuse.org
        - is_redirect_features   hdr_reg(host) -i (idea|ideas).opensuse.org
        - is_forums              hdr(host)     -i forums.opensuse.org
        - is_freeipa             hdr(host)     -i freeipa.infra.opensuse.org
        - is_gcc                 hdr(host)     -i gcc.opensuse.org
        - is_gitlab              hdr(host)     -i gitlab.infra.opensuse.org
        - is_gitlab              hdr(host)     -i gitlab.opensuse.org
        - is_hackweek            hdr(host)     -i hackweek.opensuse.org
        - is_hackweeksc          hdr(host)     -i hackweek.suse.com
        - is_ignite_stage        hdr(host)     -i ignite-stage.opensuse.org
        - is_ignite              hdr(host)     -i ignite.opensuse.org
        - is_deadservice         hdr(host)     -i hellocf.opensuse.org
        - is_help                hdr(host)     -i help.opensuse.org
        {%- for host_hydra in ['hydra', 'anna', 'elsa', 'proxy-ipx1'] %}
        - is_hydra               hdr(host)     -i {{ host_hydra }}.opensuse.org
        {%- endfor %}
        - is_deadservice         hdr(host)     -i icc.opensuse.org
        - is_get_o_o             hdr(host)     -i get.opensuse.org
        {%- for host_jekyll in ['101', 'planet', 'news', 'news-test', 'search-test', 'search', 'universe', 'yast'] %}
        - is_jekyll              hdr(host)     -i {{ host_jekyll }}.opensuse.org
        {%- endfor %}
        - is_www_test            hdr(host)     -i www-test.opensuse.org
        - is_kubic               hdr(host)     -i kubic.opensuse.org
        - is_license             hdr(host)     -i license.opensuse.org
        - is_limesurvey          hdr(host)     -i survey.opensuse.org
        - is_mailman3            hdr(host)     -i lists.opensuse.org
        - is_mailman3            hdr(host)     -i lists-test.opensuse.org
        - is_mailman3            hdr(host)     -i lists.uyuni-project.org
        - is_lnt                 hdr(host)     -i lnt.opensuse.org
        - is_mainpage            hdr(host)     -i opensuse.org
        - is_man                 hdr(host)     -i man.opensuse.org
        - is_manpages            hdr(host)     -i manpages.opensuse.org
        - is_matrix              hdr(host)     -i matrix.opensuse.org
        {%- for host_chat in ['chat', 'dimension', 'webhook'] %}
        - is_chat                hdr(host)     -i {{ host_chat }}.opensuse.org
        {%- endfor %}
        - is_metrics             hdr(host)     -i metrics.opensuse.org
        - is_microos             hdr(host)     -i microos.opensuse.org
        - is_mirrorlist          hdr(host)     -i mirror.opensuse.org
        - is_mirrorlist          hdr(host)     -i mirrors.opensuse.org
        - is_mirrorlist          hdr(host)     -i mirrordb.opensuse.org
        - is_mirrorcache         hdr(host)     -i mirrorcache.opensuse.org
        - is_mirrorcache_eu      hdr(host)     -i mirrorcache-eu.opensuse.org
        - is_download_o_o        hdr(host)     -i download.opensuse.org
        - is_monitor             hdr(host)     -i monitor.opensuse.org
        - is_graylog             hdr(host)     -i graylog.opensuse.org
        - is_moodle              hdr(host)     -i moodle.opensuse.org
        - is_opi_proxy           hdr(host)     -i opi-proxy.opensuse.org
        {%- for host_pagure in ['code', 'pages', 'ev', 'releases'] %}
        - is_pagure              hdr(host)     -i {{ host_pagure }}.opensuse.org
        {%- endfor %}
        - is_paste               hdr(host)     -i paste.opensuse.org
        - is_paste               hdr(host)     -i paste-test.opensuse.org
        - is_minio               hdr(host)     -i s3.opensuse-project.net
        - is_static_o_o          hdr(host)     -i static.opensuse.org
        {%- for host_static in ['fontinfo', 'people', 'lizards', 'html5test', 'shop', 'studioexpress'] %}
        - is_staticpages         hdr(host)     -i {{ host_static }}.opensuse.org
        {%- endfor %}
        - is_obsreview           hdr(host)     -i obs-reviewlab.opensuse.org
        - is_osccollab           hdr(host)     -i osc-collab.opensuse.org
        - is_osccollab           hdr(host)     -i osc-collab-test.opensuse.org
        - is_openqa              hdr(host)     -i openqa.opensuse.org
        - is_openqa              hdr(host)     -i devel.openqa.opensuse.org
        - is_board               hdr(host)     -i board.opensuse.org
        - is_redirect_itsself    hdr(host)     -i redirector.opensuse.org
        - is_rpmlint             hdr(host)     -i rpmlint.opensuse.org
        - is_rt                  hdr(host)     -i tickets-test.opensuse.org
        - is_sso                 hdr(host)     -i sso.opensuse.org
        - is_sso                 hdr_reg(host) -i .+\.sso\.opensuse\.org
        - is_susestudio          hdr_reg(host) -i (.*\.)?susestudio.com
        - is_svn                 hdr(host)     -i svn.opensuse.org
        - is_redirect_git        hdr(host)     -i git.opensuse.org
        - is_svn                 hdr(host)     -i kernel.opensuse.org
        - is_upgrade             hdr(host)     -i upgrade.opensuse.org
        - is_nuka                hdr(host)     -i l10n.opensuse.org
        - is_nuka                hdr(host)     -i i18n.opensuse.org
        - is_test_wiki           hdr(host)     -i en-test.opensuse.org
        - is_wiki                hdr(host)     -i wiki.opensuse.org
        - is_dewiki              hdr(host)     -i dewiki.opensuse.org
        - is_mediawiki_cz        hdr(host)     -i cz.opensuse.org
        - is_mediawiki_cn        hdr(host)     -i cz.opensuse.org
        - is_wiki_gone           hdr(host)     -i fi.opensuse.org
        - is_wiki_gone           hdr(host)     -i is.opensuse.org
        - is_wiki_gone           hdr(host)     -i vi.opensuse.org
      option: http-server-close
      redirects: {{ redirects }}
      extra:
        {{ extra({
              'http-request': {
                'del-header': [
                  'X-Forwarded-For', '^X-Forwarded-(Proto|Ssl).*', '^HTTPS.*'
                ],
                'add-header': [
                  'HTTPS on if is_ssl', 'X-Forwarded-Ssl on if is_ssl', 'X-Forwarded-Ssl on if is_ssl', 'X-Forwarded-Proto https if is_ssl !is_www',
                  'X-Forwarded-Protocol https if is_ssl', 'X-Forwarded-Proto http unless is_ssl', 'X-Forwarded-Protocol http unless is_ssl'
                ],
                'deny': [
                  'if { fc_http_major 1 } !{ req.body_size 0 } !{ req.hdr(content-length) -m found } !{ req.hdr(transfer-encoding) -m found } !{ method CONNECT }'
                ] },
              'http-response': {
                'del-header': [
                  'X-Powered-By', 'Server'
                ],
                'set-header': [
                  'X-Frame-Options SAMEORIGIN if is_ssl !no_x-frame-option', 'X-XSS-Protection "1; mode=block" if is_ssl', 'X-Content-Type-Options nosniff if is_ssl',
                  'X-Content-Type-Options nosniff if is_ssl', 'X-Content-Type-Options nosniff if is_ssl', 'X-Content-Type-Options nosniff if is_ssl',
                  'Referrer-Policy no-referrer-when-downgrade if is_ssl', 'Strict-Transport-Security max-age=15768000'
                ] }
        }) }}
        - http-request set-var(txn.host) hdr(Host)
      use_backends:
        - error_403        if is_dot_scm
        - security_txt     if is_security
        - bugzilla-devel   if is_bugzilla_devel
        - jenkins          if is_jenkins
        - community        if is_community
        - pinot            if is_doc is_relnotes
        - community        if is_doc
        - community2       if is_community2
        - pinot            if is_counter
        - pinot            if is_contribute
        - pinot            if is_pmya
        - conncheck        if is_conncheck
        - deadservices     if is_features || is_deadservice
        - etherpad         if is_etherpad
        - fedora-sso       if is_sso
        - forums           if is_forums
        - freeipa          if is_freeipa
        - gccstats         if is_gcc
        - mickey           if is_gitlab
        - hackweek         if is_hackweek
        - hydra            if is_hydra is_ssl
        - nuka             if is_nuka
        - jekyll           if is_jekyll || is_www_test || is_get_o_o
        - kubic            if is_kubic
        - kubic            if is_microos
        - kubic            if is_mainpage is_kubic_registry
        - limesurvey       if is_limesurvey
        - mailman3         if is_mailman3
        - lnt              if is_lnt
        - man              if is_manpages
        - matrix           if is_matrix
        - chat             if is_chat
        - metrics          if is_metrics
        - mirrorlist       if is_mirrorlist
        - mirrorcache      if is_mirrorcache
        - mirrorcache      if is_download_o_o
        - mirrorcache-eu   if is_mirrorcache_eu
        - jekyll           if is_slash is_monitor
        - monitor_grafana  if is_grafana is_monitor
        - monitor          if is_monitor
        - moodle           if is_moodle
        - pagure           if is_pagure
        - opi_proxy        if is_opi_proxy
        - www_openid_ldap  if is_www is_slash_openid_ldap
        - staticpages      if is_www || is_staticpages || is_static_o_o
        - osccollab        if is_osccollab
        - obsreview        if is_obsreview
        - openqa           if is_openqa
        - paste            if is_paste
        - minio            if is_minio
        - rpmlint          if is_rpmlint
        - svn              if is_svn
        - os_rt            if is_rt
      default_backend: redirect_www_o_o
    http-int-in:
      bind:
        {{ bind(['127.0.0.1'], 83, bindopts_proxy) }}
        {{ bind(['192.168.47.4', '192.168.87.5'], 80, bindopts) }}
      option: http-server-close
      acls:
        - is_dot_scm             path_beg      /.git/
        - is_dot_scm             path_beg      /.svn/
        - is_dot_scm             path_beg      /.bzr/
        - is_ssl                 fc_rcvd_proxy
        - is_connect             hdr_reg(host) -i connect(-dev)?\.opensuse\.org
        - is_connect             hdr(host) -i users.opensuse.org
        - is_dale                hdr(host) -i events.opensuse.org
        - is_dale                hdr(host) -i events-test.opensuse.org
        - is_download            hdr(host) -i download.opensuse.org
        - is_download            hdr(host) -i download.infra.opensuse.org
        - is_download            hdr(host) -i widehat.opensuse.org
        - is_elections           hdr(host) -i elections.opensuse.org
        - is_forums              hdr(host) -i forums.opensuse.org
        - is_hackweek            hdr(host) -i hackweek.opensuse.org
        - is_hydra               hdr(host) -i hydra.opensuse.org
        {%- for wiki in ['cn', 'cs', 'de', 'el', 'en', 'es', 'files', 'fr', 'hu', 'it', 'ja', 'languages', 'nl', 'old-en', 'old-de', 'pl', 'pt', 'ru', 'sv', 'tr', 'zh', 'zh-tw'] %}
        - is_mediawiki_{{ wiki }} hdr(host) -i {{ wiki }}.opensuse.org
        {%- endfor %}
        - is_mickey              hdr(host) -i gitlab.infra.opensuse.org
        - is_openqa              hdr(host) -i openqa.opensuse.org
        - is_redmine             hdr(host) -i progress.opensuse.org
        - is_redmine             hdr(host) -i tickets.opensuse.org
        - is_redmine_test        hdr(host) -i progress-test.opensuse.org
        - is_smt                 hdr(host) -i smt-internal.infra.opensuse.org
        - is_static_via_login    hdr(host) -i static.opensuse.org
        - is_test_wiki           hdr(host) -i en-test.opensuse.org
        - is_tsp                 hdr(host) -i tsp.opensuse.org
        - is_tsp                 hdr(host) -i tsp-test.opensuse.org
      extra:
        {{ extra({
              'http-request': {
                'del-header': [
                  'X-Forwarded-For', '^X-Forwarded-(Proto|Ssl).*', '^HTTPS.*'
                ],
                'add-header': [
                  'HTTPS on if is_ssl', 'X-Forwarded-Ssl on if is_ssl', 'X-Forwarded-Proto https if is_ssl', 'X-Forwarded-Protocol https if is_ssl',
                  'X-Forwarded-Proto http unless is_ssl', 'X-Forwarded-Protocol http unless is_ssl'
                ] },
              'http-response': {
                'add-header': [
                  'Strict-Transport-Security max-age=31536000;includeSubDomains;preload if is_ssl'
                ] }
        }) }}
      use_backends:
        - error_403        if is_dot_scm
        - dale             if is_dale
        - deadservices     if is_connect
        - download-private if is_download
        - elections        if is_elections
        - hackweek         if is_hackweek
        - hydra            if is_hydra
        - mickey           if is_mickey
        - openqa           if is_openqa
        - redmine          if is_redmine
        - redmine_test     if is_redmine_test
        - smt              if is_smt
        - staticpages      if is_static_via_login
        - forums           if is_forums
        - tsp              if is_tsp
        - riesling         if is_test_wiki || is_mediawiki_cn || is_mediawiki_cs || is_mediawiki_de || is_mediawiki_el || is_mediawiki_en || is_mediawiki_es || is_mediawiki_files || is_mediawiki_fr || is_mediawiki_hu || is_mediawiki_it || is_mediawiki_ja || is_mediawiki_languages || is_mediawiki_nl || is_mediawiki_old-en || is_mediawiki_old-de || is_mediawiki_pl || is_mediawiki_pt || is_mediawiki_ru || is_mediawiki_sv || is_mediawiki_tr || is_mediawiki_zh || is_mediawiki_zh-tw
      default_backend: redirect_www_o_o
  backends:
    redirect_www_o_o:
      redirect: code 301 location https://www.opensuse.org/
    staticpages:
      {{ options('httpchk OPTIONS /check.txt HTTP/1.1\r\nHost:\ fontinfo.opensuse.org') }}
      balance: roundrobin
      mode: http
      servers:
        {%- for server, address in narwals.items() %}
        {{ server }}:
          host: {{ address }}
          port: 80
          check: check
        {%- endfor %}
    www_openid_ldap:
      {{ options() }}
      {{ server('ldap-proxy', '192.168.47.3') }}
      mode: http
    community2:
      {{ options('httpchk OPTIONS /check.txt HTTP/1.1\r\nHost:\ factory-dashboard.opensuse.org') }}
      mode: http
      {{ server('community2', '192.168.47.79') }}
    bugzilla-devel:
      options:
        - tcpka
        - httpchk GET /index.cgi
      {{ server('bugzilla-devel', '195.135.220.27', 443, extra_extra='ssl verify none') }}
    bugzilla:
      {{ options('httpchk OPTIONS /check.txt HTTP/1.1\r\nHost:\ bugzilla.opensuse.org') }}
      balance: roundrobin
      mode: http
      servers:
        {%- for server, address in narwals.items() %}
        {%- if not server == 'narwal4' %} {#- why ??? #}
        {{ server }}:
          host: {{ address }}
          port: 80
          check: check
        {%- endif %}
        {%- endfor %}
    community:
      {{ options ('httpchk OPTIONS / HTTP/1.1\r\nHost:\ community.opensuse.org') }}
      {{ server('community', '192.168.47.6') }}
    svn:
      {{ options() }}
      {{ server('svn', '192.168.47.25') }}
    dale:
      {{ options('httpchk HEAD /robots.txt HTTP/1.1\r\nHost:\ events.opensuse.org') }}
      {{ server('dale', '192.168.47.52', 80) }}
    kubic:
      {{ options ('httpchk HEAD /check.txt HTTP/1.1\r\nHost:\ kubic.opensuse.org') }}
      {{ server('kubic', '192.168.47.30') }}
    monitor:
      {{ options ('httpchk HEAD /check.txt HTTP/1.1\r\nHost:\ monitor.opensuse.org') }}
      {{ server('monitor', '192.168.47.7', extra_extra='inter 30000') }}
    monitor_grafana:
      {{ options(check_txt) }}
      {{ server('limesurvey', '192.168.47.12', extra_extra='inter 5000') }}
    limesurvey:
      {{ options(check_txt) }}
      {{ server('limesurvey', '192.168.47.12', extra_extra='inter 5000') }}
    mailman3:
      acls:
        - is_lists_test hdr_reg(host) -i (.*)-test\.opensuse\.org
      {{ options() }}
      {{ server('mailman3', '192.168.47.80', extra_extra='inter 30000') }}
    rpmlint:
      errorfiles:
        503: /etc/haproxy/errorfiles/downtime.xml
      timeouts:
        - check 30s
        - server 30m
      {{ options() }}
      {{ server('rpmlint', '192.168.47.53', extra_extra='inter 5000') }}
    error_403:
      mode: http
      options: ['tcpka']
      extra: http-request set-log-level silent
      errorfiles:
        503: /etc/haproxy/errorfiles/403.html
    etherpad:
      {{ options() }}
      errorfiles:
        503: /etc/haproxy/errorfiles/downtime.html
      extra: http-request del-header X-Frame-Options
      timeouts:
        - check 30s
        - server 30m
      {{ server('etherpad', '192.168.47.56', 9001, extra_extra='inter 5000') }}
    osccollab:
      mode: http
      {{ options ('httpchk OPTIONS /check.txt HTTP/1.1\r\nHost:\ osc-collab.opensuse.org') }}
      {{ server('osccollab2', '192.168.47.64') }}
    openqa:
      {{ options() }}
      {{ server('openqa1', '192.168.47.13') }}
    redmine:
      {{ options ('httpchk HEAD / HTTP/1.1\r\nHost:\ progress.opensuse.org') }}
      {{ server('progress', '192.168.47.8', extra_extra='maxconn 16') }}
    redmine_test:
      {{ options ('httpchk HEAD / HTTP/1.1\r\nHost:\ progress.opensuse.org') }}
      {{ server('progressoo', '192.168.47.34', 3001, extra_extra='maxconn 16') }}
    download:
      options:
        - forwardfor header X-Forwarded-999
        - tcpka
      {{ server('download', '195.135.221.134') }}
    download-private:
      {{ options() }}
      {{ server('download-private', '192.168.47.73') }}
    smt:
      {{ options() }}
      {{ server('smt-internal', '195.135.221.141') }}
    mickey:
      {{ options() }}
      {{ server('mickey', '192.168.47.36', 443, extra_check='ssl verify none') }}
      {#- original had the mickey check port set to 80 - my macro does not support checking a different port, I assume the original was a mistake #}
    moodle:
      mode: http
      {{ options ('httpchk OPTIONS /check.txt HTTP/1.1\r\nHost:\ moodle.opensuse.org') }}
      {{ server('moodle', '192.168.47.58', extra_extra='inter 5000') }}
    opi_proxy:
      mode: http
      {{ options() }}
      {{ server('opi_proxy', '192.168.47.50', extra_extra='inter 5000') }}
    pagure:
      mode: http
      {{ options() }}
      {{ server('pagure', '192.168.47.84', extra_extra='inter 5000') }}
    pagure_ssh:
      mode: tcp
      {{ server('pagure_ssh', '192.168.47.84', 22, check=None) }}
    gccstats:
      {{ options() }}
      {{ server('gccstats', '192.168.47.71') }}
    nuka:
      {{ options ('httpchk HEAD /static/weblate-128.png HTTP/1.1\r\nHost:\ l10n.opensuse.org') }}
      {{ server('nuka', '192.168.47.62') }}
    freeipa:
      {{ options() }}
      {{ server('freeipa', '192.168.47.65', 443, extra_check='ssl ca-file /etc/haproxy/freeipa-ca.crt') }}
    conncheck:
      mode: http
      options: ['tcpka']
      extra: 'http-request set-log-level silent'
      errorfiles:
        503: /etc/haproxy/errorfiles/conncheck.reply.txt
    deadservices:
      options: ['tcpka']
      mode: http
      errorfiles:
        503: /etc/haproxy/errorfiles/deprecated.html.http
    hackweek:
      mode: http
      {{ options() }}
      {{ server('dale_hackweek', '192.168.47.52', 81) }}
    mirrorlist:
      {{ options() }}
      {{ server('olaf', '192.168.47.17') }}
    mirrorcache:
      {{ options() }}
      {{ server('mirrorcache', '192.168.47.73') }}
    mirrorcache-eu:
      {{ options() }}
      {{ server('mirrorcache2', '192.168.47.28', 3000) }}
    hydra:
      stats:
        enable: true
        hide-version: ''
        uri: /
        refresh: 5s
        realm: Monitor
        auth: '"$STATS_USER":"$STATS_PASSPHRASE"'
    pinot:
      {{ options() }}
      {{ server('pinot', '192.168.47.11') }}
    riesling:
      {{ options() }}
      {{ server('riesling', '192.168.47.42', check=None) }}
    forums:
      {{ options() }}
      {{ server('discourse01', '192.168.47.83') }}
    tsp:
      {{ options() }}
      {{ server('tsp', '192.168.47.9') }}
    elections:
      {{ options() }}
      {{ server('elections2', '192.168.47.32') }}
    jenkins:
      options:
        - forwardfor
        - httpchk HEAD / HTTP/1.1\r\nHost:\ ci.opensuse.org
      {{ server('ci-opensuse', '192.168.47.77', 8080) }}
    metrics:
      {{ options() }}
      {{ server('metrics', '192.168.47.31', 3000) }}
    lnt:
      {{ options() }}
      {{ server('lnt', '192.168.47.35') }}
      httprequests:
      - set-header X-Forwarded-Host %[req.hdr(Host)]
      - set-header X-Forwarded-Proto https
    obsreview:
      {{ options() }}
      {{ server('obsreview', '192.168.47.39') }}
    os_rt:
      {{ options ('httpchk HEAD /check/check.txt HTTP/1.1\r\nHost:\ tickets-test.opensuse.org') }}
      {{ server('os-rt', '192.168.47.48') }}
    security_txt:
      mode: http
      options:
        - tcpka
      errorfiles:
        503: /etc/haproxy/errorfiles/security.txt
      extra: http-request set-log-level silent
    jekyll:
      {{ options('httpchk OPTIONS / HTTP/1.1\r\nHOST:\ search.opensuse.org') }}
      {{ server('jekyll', '192.168.47.61') }}
      acls:
        - is_jekyll_test          hdr_reg(host) -i (.*)-test\.opensuse\.org
      extra: http-request replace-header HOST (.*)-test(.*) \1\2 if is_jekyll_test
    matrix:
      {{ options() }}
      {{ server('matrix', '192.168.47.78', 8008) }}
    chat:
      {{ options() }}
      {{ server('matrix', '192.168.47.78') }}
    fedora-sso:
      {{ options('httpchk OPTIONS / HTTP/1.1\r\nHOST:\ sso.opensuse.org') }}
      {{ server('fedora-sso', '192.168.47.81') }}
    wip:
      mode: http
      errorfiles:
        503: /etc/haproxy/fourohfour.html.response
      extra: http-request set-log-level silent
    man:
      {{ options() }}
      {{ server('man', '192.168.47.29') }}
    minio:
      {{ options() }}
      {{ server('minio', '192.168.47.55') }}
    paste:
      {{ options() }}
      {{ server('paste', '192.168.47.74') }}

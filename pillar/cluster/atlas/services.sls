haproxy:
  frontends:
    http:
      acls:
        - no_x-frame-option var(txn.host) -m str chat.opensuse.org
        - no_x-frame-option var(txn.host) -m str dimension.opensuse.org
        - no_x-frame-option var(txn.host) -m str etherpad.opensuse.org

        # login2.o.o via anna/elsa
        - src_login         src         2a07:de40:b27e:64::c0a8:2f65 2a07:de40:b27e:64::c0a8:2f66

        - is_ssl            dst_port    443

        - path_dot_scm           path_beg    /.git/
        - path_dot_scm           path_beg    /.svn/
        - path_dot_scm           path_beg    /.bzr/
        - path_favicon           path        /favicon.ico
        - path_grafana           path_beg    /grafana/
        - path_kubic_registry    path_beg    /v2/
        - path_matrix_client     path_beg    /.well-known/matrix/client
        - path_matrix_federation path_beg    /.well-known/matrix/server
        - path_openid            path_beg    -i /openid
        - path_openid            path_beg    -i /common/app/
        - path_openid            path_beg    -i /openid-ldap
        - path_openid            path_beg    -i /idp
        - host_paste             hdr(host)   -i paste.opensuse.org
        - host_paste             hdr(host)   -i paste-test.opensuse.org
        - path_relnotes          path_beg    /release-notes/
        - path_security          path_end    /.well-known/security.txt
        - path_searchpage        path_beg    -i /searchPage
        - path_slash             path         /

        - host_beans        hdr(host)   -i beans.opensuse.org
        {%- for host_chat in ['chat', 'dimension', 'webhook'] %}
        - host_chat         hdr(host)   -i {{ host_chat }}.opensuse.org
        {%- endfor %}
        - host_community    hdr(host)   -i community.opensuse.org
        - host_community2   hdr(host)   -i factory-dashboard.opensuse.org
        - host_contribute   hdr(host)   -i contribute.opensuse.org
        - host_counter      hdr_reg(host) -i count(er|down)\.opensuse\.org
        - host_doc          hdr(host)   -i doc.opensuse.org
        - host_redirect_doc hdr_reg(host) -i (docs|activedoc|www\.activedoc|rtfm).opensuse.org
        - host_etherpad     hdr(host)   -i etherpad.opensuse.org
        - host_dale         hdr(host)   -i events.opensuse.org
        - host_dale         hdr(host)   -i events-test.opensuse.org
        - host_deadservice  hdr(host)   -i connect.opensuse.org
        - host_deadservice  hdr(host)   -i fate.opensuse.org
        - host_deadservice  hdr(host)   -i features.opensuse.org
        - host_deadservice  hdr_reg(host) -i (idea|ideas).opensuse.org
        - host_deadservice  hdr(host)   -i hellocf.opensuse.org
        - host_deadservice  hdr(host)   -i moodle.opensuse.org
        - host_deadservice  hdr(host)   -i users.opensuse.org
        - host_elections    hdr(host)   -i elections.opensuse.org
        - host_forums       hdr(host)   -i forums.opensuse.org
        - host_gcc          hdr(host)   -i gcc.opensuse.org
        - host_get_o_o      hdr(host)   -i get.opensuse.org
        - host_hackweek     hdr(host)   -i hackweek.opensuse.org
        {%- for host_jekyll in ['101', 'planet', 'news', 'news-test', 'search-test', 'search', 'universe', 'yast'] %}
        - host_jekyll       hdr(host)   -i {{ host_jekyll }}.opensuse.org
        {%- endfor %}
        - host_kubic        hdr(host)   -i kubic.opensuse.org
        - host_limesurvey   hdr(host)   -i survey.opensuse.org
        - host_lnt          hdr(host)   -i lnt.opensuse.org
        - host_mailman3     hdr(host)   -i lists.opensuse.org
        - host_mailman3     hdr(host)   -i lists.uyuni-project.org
        - host_mainpage     hdr(host)   -i opensuse.org
        - host_man          hdr(host)   -i man.opensuse.org
        - host_manpages     hdr(host)   -i manpages.opensuse.org
        - host_matrix       hdr(host)   -i matrix.opensuse.org
        - host_microos      hdr(host)   -i microos.opensuse.org
        - host_minio        hdr(host)   -i s3.opensuse-project.net
        - host_monitor      hdr(host)   -i monitor.opensuse.org
        - host_nuka         hdr(host)   -i i18n.opensuse.org
        - host_nuka         hdr(host)   -i l10n.opensuse.org
        - host_opi_proxy    hdr(host)   -i opi-proxy.opensuse.org
        - host_osc_collab   hdr(host)   -i osc-collab.opensuse.org
        - host_osc_collab   hdr(host)   -i osc-collab-test.opensuse.org
        - host_pmya         hdr(host)   -i pmya.opensuse.org
        - host_redmine      hdr(host)   -i progress.opensuse.org
        - host_rpmlint      hdr(host)   -i rpmlint.opensuse.org
        - host_static_o_o   hdr(host)   -i static.opensuse.org
        {%- for host_static in ['fontinfo', 'people', 'lizards', 'html5test', 'shop', 'studioexpress', 'oom'] %}
        - host_staticpages  hdr(host)   -i {{ host_static }}.opensuse.org
        {%- endfor %}
        - host_svn            hdr(host)   -i svn.opensuse.org
        - host_svn            hdr(host)   -i kernel.opensuse.org
        - host_tsp            hdr(host)   -i tsp.opensuse.org
        - host_tsp            hdr(host)   -i tsp-test.opensuse.org
        {%- for wiki in ['cn', 'cs', 'de', 'el', 'en', 'es', 'files', 'fr', 'hu', 'it', 'ja', 'languages', 'nl', 'old-en', 'old-de', 'pl', 'pt', 'ru', 'sv', 'tr', 'zh', 'zh-tw', 'en-test'] %}
        - host_mediawiki    hdr(host) -i {{ wiki }}.opensuse.org
        {%- endfor %}
        - host_www            hdr(host)   -i www.opensuse.org
        - host_www_test       hdr(host)   -i www-test.opensuse.org

      default_backend: redirect_www_o_o
      use_backends:
        # special paths with common handling for all hosts
        - error_403           if path_dot_scm
        - matrix-client       if path_matrix_client
        - matrix-federation   if path_matrix_federation
        - security_txt        if path_security

        # path-specific rules
        - jekyll          if host_monitor path_slash
        #- kubic          if host_mainpage path_kubic_registry
        - monitor_grafana if host_monitor path_grafana
        - pinot           if host_doc path_relnotes
        - www_openid_ldap if host_www path_openid

        # hosts only reachable via login2.o.o
        - dale            if src_login host_dale
        - elections       if src_login host_elections
        - tsp             if src_login host_tsp
        - riesling        if src_login host_mediawiki

        # rules only depending on host_*
        - chat            if host_chat
        - community       if host_community
        - community       if host_doc
        - community2      if host_community2
        - deadservices    if host_deadservice
        - etherpad        if host_etherpad
        - forums          if host_forums
        - gccstats        if host_gcc
        - hackweek        if host_hackweek
        - jekyll          if host_jekyll || host_www_test || host_get_o_o
        - kubic           if host_kubic
        - kubic           if host_microos
        - limesurvey      if host_limesurvey
        - lnt             if host_lnt
        - mailman3        if host_mailman3
        - man             if host_manpages
        - matomo          if host_beans
        - matrix          if host_matrix
        - minio           if host_minio
        - monitor         if host_monitor
        - nuka            if host_nuka
        - opi_proxy       if host_opi_proxy
        - osc_collab      if host_osc_collab
        - paste           if host_paste
        - pinot           if host_contribute
        - pinot           if host_counter
        - pinot           if host_pmya
        - redmine         if host_redmine
        - rpmlint         if host_rpmlint
        - staticpages     if host_www || host_staticpages || host_static_o_o
        - svn             if host_svn

      redirects:
        - scheme https code 301                                              if !is_ssl !host_get_o_o
        - code 301 location https://doc.opensuse.org                         if host_redirect_doc
        - code 302 location https://manpages.opensuse.org                    if host_man
        - code 301 location https://search.opensuse.org                      if host_www path_searchpage
        - code 301 location https://static.opensuse.org/favicon.ico code 302 if path_favicon host_mailman3
        - code 301 location https://static.opensuse.org/favicon.ico code 302 if path_favicon host_staticpages
        - code 301 location https://static.opensuse.org/favicon.ico code 302 if path_favicon host_www
        - code 301 prefix   https://www.opensuse.org                         if host_mainpage !path_kubic_registry !path_matrix_client !path_matrix_federation

    http-misc:
      acls:
        {%- for host_pagure in ['code', 'pages', 'ev', 'releases'] %}
        - host_pagure     hdr(host)   -i {{ host_pagure }}.opensuse.org
        {%- endfor %}
      use_backends:
        - pagure          if host_pagure

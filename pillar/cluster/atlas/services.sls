haproxy:
  frontends:
    http:
      acls:
        - no_x-frame-option var(txn.host) -m str chat.opensuse.org
        - no_x-frame-option var(txn.host) -m str dimension.opensuse.org
        - no_x-frame-option var(txn.host) -m str etherpad.opensuse.org
        - no_x-frame-option var(txn.host) -m str metrics.opensuse.org

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
        - host_manpages     hdr(host)   -i manpages.opensuse.org
        - host_matrix       hdr(host)   -i matrix.opensuse.org
        - host_metrics      hdr(host)   -i metrics.opensuse.org
        - host_microos      hdr(host)   -i microos.opensuse.org
        - host_minio        hdr(host)   -i s3.opensuse-project.net
        - host_monitor      hdr(host)   -i monitor.opensuse.org
        - host_nuka         hdr(host)   -i i18n.opensuse.org
        - host_nuka         hdr(host)   -i l10n.opensuse.org
        - host_obsreview    hdr(host)   -i obs-reviewlab.opensuse.org
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
        - host_tsp            hdr(host)   -i tsp.opensuse.org
        - host_tsp            hdr(host)   -i tsp-test.opensuse.org
        {%- for wiki in ['cn', 'cs', 'de', 'el', 'en', 'es', 'files', 'fr', 'hu', 'it', 'ja', 'languages', 'nl', 'old-en', 'old-de', 'pl', 'pt', 'ru', 'sv', 'tr', 'zh', 'zh-tw', 'en-test'] %}
        - host_mediawiki    hdr(host) -i {{ wiki }}.opensuse.org
        {%- endfor %}
        - host_www            hdr(host)   -i www.opensuse.org
        - host_www_test       hdr(host)   -i www-test.opensuse.org

        # hostnames only used for domain-level redirects
        - host_redirect_apparmor   hdr(host)     -i apparmor.opensuse.org
        - host_redirect_bar        hdr(host)     -i bar.opensuse.org
        - host_redirect_board      hdr(host)     -i board.opensuse.org
        - host_redirect_bugs       hdr(host)     -i bugs.opensuse.org
        - host_redirect_coc        hdr(host)     -i coc.opensuse.org
        - host_redirect_doc        hdr_reg(host) -i (docs|activedoc|www\.activedoc|rtfm).opensuse.org
        - host_redirect_education  hdr(host)     -i education.opensuse.org
        - host_redirect_events     hdr(host)     -i conference.opensuse.org
        - host_redirect_events     hdr(host)     -i events-test.opensuse.org
        - host_redirect_events     hdr(host)     -i party.opensuse.org
        - host_redirect_events     hdr(host)     -i summit.opensuse.org
        - host_redirect_git        hdr(host)     -i git.opensuse.org
        - host_redirect_help       hdr(host)     -i help.opensuse.org
        - host_redirect_ignite     hdr(host)     -i ignite-stage.opensuse.org
        - host_redirect_ignite     hdr(host)     -i ignite.opensuse.org
        - host_redirect_license    hdr(host)     -i license.opensuse.org
        - host_redirect_man        hdr(host)     -i man.opensuse.org
        - host_redirect_susestudio hdr_reg(host) -i (.*\.)?susestudio.com
        - host_redirect_tube       hdr(host)     -i tube.opensuse.org
        - host_redirect_upgrade    hdr(host)     -i upgrade.opensuse.org
        - host_redirect_wiki       hdr(host)     -i wiki.opensuse.org
        - host_redirect_wiki_de    hdr(host)     -i dewiki.opensuse.org
        - host_redirect_wiki_gone  hdr(host)     -i fi.opensuse.org
        - host_redirect_wiki_gone  hdr(host)     -i is.opensuse.org
        - host_redirect_wiki_gone  hdr(host)     -i vi.opensuse.org

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
        - metrics         if host_metrics
        - minio           if host_minio
        - monitor         if host_monitor
        - nuka            if host_nuka
        - obsreview       if host_obsreview
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
        - code 301 location https://search.opensuse.org                      if host_www path_searchpage
        - code 301 location https://static.opensuse.org/favicon.ico code 302 if path_favicon host_mailman3
        - code 301 location https://static.opensuse.org/favicon.ico code 302 if path_favicon host_staticpages
        - code 301 location https://static.opensuse.org/favicon.ico code 302 if path_favicon host_www
        - code 301 prefix   https://www.opensuse.org                         if host_mainpage !path_kubic_registry !path_matrix_client !path_matrix_federation

        # redirects with host_redirect_*-only condition
        - code 301 location https://gitlab.com/apparmor/apparmor/wikis/home  if host_redirect_apparmor
        - code 302 location https://meet.opensuse.org/bar                    if host_redirect_bar
        - code 301 location https://progress.opensuse.org/projects/opensuse-board if host_redirect_board
        - code 301 location https://en.opensuse.org/openSUSE:Submitting_bug_reports if host_redirect_bugs
        - code 302 location https://en.opensuse.org/Code_of_Conduct          if host_redirect_coc
        - code 301 location https://doc.opensuse.org                         if host_redirect_doc
        - code 301 location https://en.opensuse.org/Portal:Education         if host_redirect_education
        - code 301 prefix   https://events.opensuse.org                      if host_redirect_events
        - code 301 location https://en.opensuse.org/Git                      if host_redirect_git
        - code 301 location https://en.opensuse.org/Portal:Support           if host_redirect_help
        - code 302 location https://opensuse.github.io/fuel-ignition/        if host_redirect_ignite
        - code 301 location https://github.com/openSUSE/obs-service-format_spec_file/blob/master/README.md if host_redirect_license
        - code 302 location https://manpages.opensuse.org                    if host_redirect_man
        - code 301 location https://studioexpress.opensuse.org               if host_redirect_susestudio
        - code 301 location https://www.youtube.com/user/opensusetv          if host_redirect_tube
        - code 301 location https://en.opensuse.org/Upgrade                  if host_redirect_upgrade
        - code 301 prefix   https://en.opensuse.org                          if host_redirect_wiki
        - code 301 prefix   https://de.opensuse.org                          if host_redirect_wiki_de
        - code 301 prefix   https://languages.opensuse.org                   if host_redirect_wiki_gone

    http-misc:
      acls:
        {%- for host_pagure in ['code', 'pages', 'ev', 'releases'] %}
        - host_pagure     hdr(host)   -i {{ host_pagure }}.opensuse.org
        {%- endfor %}
      use_backends:
        - pagure          if host_pagure

haproxy:
  frontends:
    http:
      acls:
        - no_x-frame-option var(txn.host) -m str etherpad.opensuse.org

        # login2.o.o via anna/elsa
        - src_login         src         2a07:de40:b27e:64::c0a8:2f65 2a07:de40:b27e:64::c0a8:2f66

        - is_ssl            dst_port    443

        - path_dot_scm      path_beg    /.git/
        - path_dot_scm      path_beg    /.svn/
        - path_dot_scm      path_beg    /.bzr/
        - path_favicon      path        /favicon.ico
        - path_grafana      path_beg    /grafana/
        - path_openid       path_beg    -i /openid
        - path_openid       path_beg    -i /common/app/
        - path_openid       path_beg    -i /openid-ldap
        - path_openid       path_beg    -i /idp
        - host_paste        hdr(host)   -i paste.opensuse.org
        - host_paste        hdr(host)   -i paste-test.opensuse.org
        - path_relnotes     path_beg    /release-notes/
        - path_security     path_end    /.well-known/security.txt
        - path_searchpage   path_beg    -i /searchPage
        - path_slash        path         /

        - host_beans        hdr(host)   -i beans.opensuse.org
        - host_community    hdr(host)   -i community.opensuse.org
        - host_community2   hdr(host)   -i factory-dashboard.opensuse.org
        - host_contribute   hdr(host)   -i contribute.opensuse.org
        - host_counter      hdr_reg(host) -i count(er|down)\.opensuse\.org
        - host_doc          hdr(host)   -i doc.opensuse.org
        - host_redirect_doc hdr_reg(host) -i (docs|activedoc|www\.activedoc|rtfm).opensuse.org
        - host_etherpad     hdr(host)   -i etherpad.opensuse.org
        - host_dale         hdr(host)   -i events.opensuse.org
        - host_dale         hdr(host)   -i events-test.opensuse.org
        - host_get_o_o      hdr(host)   -i get.opensuse.org
        - host_hackweek     hdr(host)   -i hackweek.opensuse.org
        {%- for host_jekyll in ['101', 'planet', 'news', 'news-test', 'search-test', 'search', 'universe', 'yast'] %}
        - host_jekyll       hdr(host)   -i {{ host_jekyll }}.opensuse.org
        {%- endfor %}
        - host_limesurvey   hdr(host)   -i survey.opensuse.org
        - host_man          hdr(host)   -i man.opensuse.org
        - host_manpages     hdr(host)   -i manpages.opensuse.org
        - host_minio        hdr(host)   -i s3.opensuse-project.net
        - host_monitor      hdr(host)   -i monitor.opensuse.org
        - host_pmya         hdr(host)   -i pmya.opensuse.org
        - host_redmine      hdr(host)   -i progress.opensuse.org
        - host_static_o_o   hdr(host)   -i static.opensuse.org
        {%- for host_static in ['fontinfo', 'people', 'lizards', 'html5test', 'shop', 'studioexpress', 'oom'] %}
        - host_staticpages  hdr(host)   -i {{ host_static }}.opensuse.org
        {%- endfor %}
        - host_tsp            hdr(host)   -i tsp.opensuse.org
        - host_tsp            hdr(host)   -i tsp-test.opensuse.org
        {%- for wiki in ['cn', 'cs', 'de', 'el', 'en', 'es', 'files', 'fr', 'hu', 'it', 'ja', 'languages', 'nl', 'old-en', 'old-de', 'pl', 'pt', 'ru', 'sv', 'tr', 'zh', 'zh-tw', 'en-test'] %}
        - host_mediawiki    hdr(host) -i {{ wiki }}.opensuse.org
        {%- endfor %}
        - host_www            hdr(host)   -i www.opensuse.org
        - host_www_test       hdr(host)   -i www-test.opensuse.org

      use_backends:
        # special paths with common handling for all hosts
        - error_403        if path_dot_scm
        - security_txt     if path_security

        # path-specific rules
        - jekyll          if host_monitor path_slash
        - monitor_grafana if host_monitor path_grafana
        - pinot           if host_doc path_relnotes
        - www_openid_ldap if host_www path_openid

        # hosts only reachable via login2.o.o
        - dale            if src_login host_dale
        - tsp             if src_login host_tsp
        - riesling        if src_login host_mediawiki

        # rules only depending on host_*
        - community       if host_community
        - community       if host_doc
        - community2      if host_community2
        - etherpad        if host_etherpad
        - hackweek        if host_hackweek
        - jekyll          if host_jekyll || host_www_test || host_get_o_o
        - limesurvey      if host_limesurvey
        - man             if host_manpages
        - matomo          if host_beans
        - minio           if host_minio
        - monitor         if host_monitor
        - paste           if host_paste
        - pinot           if host_contribute
        - pinot           if host_counter
        - pinot           if host_pmya
        - redmine         if host_redmine
        - staticpages     if host_www || host_staticpages || host_static_o_o

      redirects:
        - scheme https code 301                                              if !is_ssl !host_get_o_o
        - code 301 location https://doc.opensuse.org                         if host_redirect_doc
        - code 302 location https://manpages.opensuse.org                    if host_man
        - code 301 location https://search.opensuse.org                      if host_www path_searchpage
        - code 301 location https://static.opensuse.org/favicon.ico code 302 if path_favicon host_staticpages
        - code 301 location https://static.opensuse.org/favicon.ico code 302 if path_favicon host_www

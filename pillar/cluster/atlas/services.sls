haproxy:
  frontends:
    http:
      acls:
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
        - path_security     path_end    /.well-known/security.txt
        - path_searchpage   path_beg    -i /searchPage
        - path_slash        path         /

        - host_get_o_o      hdr(host)   -i get.opensuse.org
        {%- for host_jekyll in ['101', 'planet', 'news', 'news-test', 'search-test', 'search', 'universe', 'yast'] %}
        - host_jekyll       hdr(host)   -i {{ host_jekyll }}.opensuse.org
        {%- endfor %}
        - host_limesurvey   hdr(host)   -i survey.opensuse.org
        - host_minio        hdr(host)   -i s3.opensuse-project.net
        - host_monitor      hdr(host)   -i monitor.opensuse.org
        - host_static_o_o   hdr(host)   -i static.opensuse.org
        {%- for host_static in ['fontinfo', 'people', 'lizards', 'html5test', 'shop', 'studioexpress', 'oom'] %}
        - host_staticpages  hdr(host)   -i {{ host_static }}.opensuse.org
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
        - www_openid_ldap if host_www path_openid

        # rules only depending on host_*
        - jekyll          if host_jekyll || host_www_test || host_get_o_o
        - limesurvey      if host_limesurvey
        - minio           if host_minio
        - monitor         if host_monitor
        - paste           if host_paste
        - staticpages     if host_www || host_staticpages || host_static_o_o

      redirects:
        - scheme https code 301                                              if !is_ssl !host_get_o_o
        - code 301 location https://search.opensuse.org                      if host_www path_searchpage
        - code 301 location https://static.opensuse.org/favicon.ico code 302 if path_favicon host_staticpages
        - code 301 location https://static.opensuse.org/favicon.ico code 302 if path_favicon host_www

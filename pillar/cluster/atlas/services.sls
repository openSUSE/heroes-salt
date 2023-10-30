haproxy:
  frontends:
    http:
      acls:
        - is_ssl            dst_port    443

        - path_favicon      path        /favicon.ico
        - path_grafana      path_beg    /grafana/
        - path_openid       path_beg    -i /openid
        - path_openid       path_beg    -i /common/app/
        - path_openid       path_beg    -i /openid-ldap
        - path_openid       path_beg    -i /idp
        - path_searchpage   path_beg    -i /searchPage
        - path_slash        path         /

        - host_get_o_o      hdr(host)   -i get.opensuse.org
        {%- for host_jekyll in ['101', 'planet', 'news', 'news-test', 'search-test', 'search', 'universe', 'yast'] %}
        - host_jekyll       hdr(host)   -i {{ host_jekyll }}.opensuse.org
        {%- endfor %}
        - host_limesurvey   hdr(host)   -i survey.opensuse.org
        - host_monitor      hdr(host)   -i monitor.opensuse.org
        - host_static_o_o   hdr(host)   -i static.opensuse.org
        {%- for host_static in ['fontinfo', 'people', 'lizards', 'html5test', 'shop', 'studioexpress', 'oom'] %}
        - host_staticpages  hdr(host)   -i {{ host_static }}.opensuse.org
        {%- endfor %}
        - host_www            hdr(host)   -i www.opensuse.org
        - host_www_test       hdr(host)   -i www-test.opensuse.org
      use_backends:
        - jekyll          if host_jekyll || host_www_test || host_get_o_o
        - jekyll          if host_monitor path_slash
        - limesurvey      if host_limesurvey
        - monitor         if host_monitor
        - monitor_grafana if path_grafana
        - staticpages     if host_www || host_staticpages || host_static_o_o
        - www_openid_ldap if host_www path_openid
      redirects:
        - scheme https code 301                                              if !is_ssl !host_get_o_o
        - code 301 location https://search.opensuse.org                      if host_www path_searchpage
        - code 301 location https://static.opensuse.org/favicon.ico code 302 if path_favicon host_staticpages
        - code 301 location https://static.opensuse.org/favicon.ico code 302 if path_favicon host_www

haproxy:
  frontends:
    http:
      acls:
        - is_ssl            dst_port    443
        - path_favicon      path        /favicon.ico
        - path_openid       path_beg    -i /openid
        - path_openid       path_beg    -i /common/app/
        - path_openid       path_beg    -i /openid-ldap
        - path_openid       path_beg    -i /idp
        - host_limesurvey   hdr(host)   -i survey.opensuse.org
        - path_searchpage   path_beg    -i /searchPage
        - host_static_o_o   hdr(host)   -i static.opensuse.org
        {%- for host_static in ['fontinfo', 'people', 'lizards', 'html5test', 'shop', 'studioexpress', 'oom'] %}
        - host_staticpages  hdr(host)   -i {{ host_static }}.opensuse.org
        {%- endfor %}
        - host_www            hdr(host)   -i www.opensuse.org
      use_backends:
        - limesurvey      if host_limesurvey
        - staticpages     if host_www || host_staticpages || host_static_o_o
        - www_openid_ldap if host_www path_openid
      redirects:
        - code 301 location https://search.opensuse.org                      if host_www path_searchpage
        - code 301 location https://static.opensuse.org/favicon.ico code 302 if path_favicon host_staticpages
        - code 301 location https://static.opensuse.org/favicon.ico code 302 if path_favicon host_www

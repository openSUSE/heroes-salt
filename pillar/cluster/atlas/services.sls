haproxy:
  frontends:
    http:
      acls:
        - is_ssl          dst_port    443
        - path_favicon    path        /favicon.ico
        - is_limesurvey   hdr(host)   -i survey.opensuse.org
        - is_static_o_o   hdr(host)   -i static.opensuse.org
        {%- for host_static in ['fontinfo', 'people', 'lizards', 'html5test', 'shop', 'studioexpress', 'oom'] %}
        - is_staticpages  hdr(host)   -i {{ host_static }}.opensuse.org
        {%- endfor %}
        - is_www          hdr(host)   -i www.opensuse.org
      use_backends:
        - limesurvey      if is_limesurvey
        - staticpages     if is_staticpages || is_static_o_o
      redirects:
        - code 301 location https://static.opensuse.org/favicon.ico code 302 if path_favicon is_staticpages
        - code 301 location https://static.opensuse.org/favicon.ico code 302 if path_favicon is_www

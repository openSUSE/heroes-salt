haproxy:
  frontends:
    http-int-in:
      acls:
        - path_dot_scm           path_beg      /.git/
        - path_dot_scm           path_beg      /.svn/
        - path_dot_scm           path_beg      /.bzr/
        - is_ssl                 fc_rcvd_proxy
        - via_atlas              hdr(host) -i events.opensuse.org
        - via_atlas              hdr(host) -i events-test.opensuse.org
        - via_atlas              hdr(host) -i elections.opensuse.org
        - via_atlas              hdr(host) -i hackweek.opensuse.org
        {%- for wiki in ['cn', 'cs', 'de', 'el', 'en', 'es', 'files', 'fr', 'hu', 'it', 'ja', 'languages', 'nl', 'old-en', 'old-de', 'pl', 'pt', 'ru', 'sv', 'tr', 'zh', 'zh-tw'] %}
        - via_atlas              hdr(host) -i {{ wiki }}.opensuse.org
        {%- endfor %}
        - via_atlas              hdr(host) -i en-test.opensuse.org
        - via_atlas              hdr(host) -i tsp.opensuse.org
        - via_atlas              hdr(host) -i tsp-test.opensuse.org

      default_backend: redirect_www_o_o
      use_backends:
        - error_403        if path_dot_scm
        - via_atlas        if via_atlas

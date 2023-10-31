haproxy:
  frontends:
    http-int-in:
      acls:
        - path_dot_scm           path_beg      /.git/
        - path_dot_scm           path_beg      /.svn/
        - path_dot_scm           path_beg      /.bzr/
        - is_ssl                 fc_rcvd_proxy
        - is_connect             hdr_reg(host) -i connect(-dev)?\.opensuse\.org
        - is_connect             hdr(host) -i users.opensuse.org
        - via_atlas              hdr(host) -i events.opensuse.org
        - via_atlas              hdr(host) -i events-test.opensuse.org
        - is_download            hdr(host) -i download.opensuse.org
        - is_download            hdr(host) -i download.infra.opensuse.org
        - is_download            hdr(host) -i widehat.opensuse.org
        - is_elections           hdr(host) -i elections.opensuse.org
        - is_forums              hdr(host) -i forums.opensuse.org
        - via_atlas              hdr(host) -i hackweek.opensuse.org
        - is_hydra               hdr(host) -i hydra.opensuse.org
        {%- for wiki in ['cn', 'cs', 'de', 'el', 'en', 'es', 'files', 'fr', 'hu', 'it', 'ja', 'languages', 'nl', 'old-en', 'old-de', 'pl', 'pt', 'ru', 'sv', 'tr', 'zh', 'zh-tw'] %}
        - via_atlas              hdr(host) -i {{ wiki }}.opensuse.org
        {%- endfor %}
        - is_mickey              hdr(host) -i gitlab.infra.opensuse.org
        - is_openqa              hdr(host) -i openqa.opensuse.org
        - via_atlas              hdr(host) -i progress.opensuse.org
        - is_redmine_test        hdr(host) -i progress-test.opensuse.org
        - is_smt                 hdr(host) -i smt-internal.infra.opensuse.org
        - via_atlas              hdr(host) -i en-test.opensuse.org
        - via_atlas              hdr(host) -i tsp.opensuse.org
        - via_atlas              hdr(host) -i tsp-test.opensuse.org

      default_backend: redirect_www_o_o
      use_backends:
        - error_403        if path_dot_scm
        - deadservices     if is_connect
        - download-private if is_download
        - elections        if is_elections
        - hydra            if is_hydra
        - mickey           if is_mickey
        - openqa           if is_openqa
        - redmine_test     if is_redmine_test
        - smt              if is_smt
        - forums           if is_forums
        - via_atlas        if via_atlas

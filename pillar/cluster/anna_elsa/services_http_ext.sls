haproxy:
  frontends:
    http-ext-in:
      acls:
        - no_x-frame-option var(txn.host) -m str meet.opensuse.org
        - is_ssl                 fc_rcvd_proxy
        - path_dot_scm           path_beg      /.git/
        - path_dot_scm           path_beg      /.svn/
        - path_dot_scm           path_beg      /.bzr/
        - path_security          path_end      /.well-known/security.txt
        - path_favicon           path          /favicon.ico
        - is_www                 hdr(host)     -i www.opensuse.org
        - is_jenkins             hdr(host)     -i ci.opensuse.org
        - is_conncheck           hdr(host)     -i conncheck.opensuse.org
        - is_hackweeksc          hdr(host)     -i hackweek.suse.com  # unused
        {%- for host_hydra in ['hydra', 'anna', 'elsa', 'proxy-ipx1'] %}
        - is_hydra               hdr(host)     -i {{ host_hydra }}.opensuse.org
        {%- endfor %}
        - is_mirrorlist          hdr(host)     -i mirror.opensuse.org
        - is_mirrorlist          hdr(host)     -i mirrors.opensuse.org
        - is_mirrorlist          hdr(host)     -i mirrordb.opensuse.org
        - is_mirrorcache         hdr(host)     -i mirrorcache.opensuse.org
        - is_mirrorcache_eu      hdr(host)     -i mirrorcache-eu.opensuse.org
        - is_download_o_o        hdr(host)     -i download.opensuse.org
        - is_graylog             hdr(host)     -i graylog.opensuse.org
        - is_redirect_itsself    hdr(host)     -i redirector.opensuse.org
        - is_test_wiki           hdr(host)     -i en-test.opensuse.org

      redirects:
        - scheme https code 301  if !is_ssl !is_conncheck !is_mirrorcache !is_mirrorcache_eu !is_download_o_o
        - code 301 location https://static.opensuse.org/favicon.ico code 302 if path_favicon is_www
        - code 301 location https://www.opensuse.org if is_redirect_itsself

      default_backend: redirect_www_o_o
      use_backends:
        - error_403        if path_dot_scm
        - security_txt     if path_security
        - jenkins          if is_jenkins
        - conncheck        if is_conncheck
        - hydra            if is_hydra is_ssl
        - mirrorlist       if is_mirrorlist
        - mirrorcache      if is_mirrorcache
        - mirrorcache      if is_download_o_o
        - mirrorcache-eu   if is_mirrorcache_eu

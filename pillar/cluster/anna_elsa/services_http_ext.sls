haproxy:
  frontends:
    http-ext-in:
      acls:
        - is_ssl                 fc_rcvd_proxy
        - path_dot_scm           path_beg      /.git/
        - path_dot_scm           path_beg      /.svn/
        - path_dot_scm           path_beg      /.bzr/
        - path_security          path_end      /.well-known/security.txt
        - is_jenkins             hdr(host)     -i ci.opensuse.org
        - is_hackweeksc          hdr(host)     -i hackweek.suse.com  # unused
        - is_test_wiki           hdr(host)     -i en-test.opensuse.org

      redirects:
        - scheme https code 301  if !is_ssl

      default_backend: redirect_www_o_o
      use_backends:
        - error_403        if path_dot_scm
        - security_txt     if path_security
        - jenkins          if is_jenkins

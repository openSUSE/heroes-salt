haproxy:
  frontends:
    http:
      acls:
        - is_ssl                 dst_port    443

        - path_dot_scm           path_beg    /.git/
        - path_dot_scm           path_beg    /.svn/
        - path_dot_scm           path_beg    /.bzr/
        - path_security          path_end    /.well-known/security.txt
        - path_matrix_client     path_beg    /.well-known/matrix/client
        - path_matrix_federation path_beg    /.well-known/matrix/server

        - host_proxy_prv         hdr(host)   -i proxy-prv.opensuse.org
        - host_conncheck         hdr(host)   -i conncheck.opensuse.org
        - host_mirrorcache_us    hdr(host)   -i mirrorcache-us.opensuse.org
        - host_static            hdr(host)   -i static.opensuse.org
        - host_static            hdr(host)   -i www.opensuse.org
        - host_mainpage          hdr(host)   -i opensuse.org

      default_backend: maintenance
      use_backends:
        - error_403              if path_dot_scm
        - conncheck              if host_conncheck
        - security_txt           if path_security
        - static                 if host_static
        - matrix-client          if path_matrix_client
        - matrix-federation      if path_matrix_federation
        - mirrorcache            if host_mirrorcache_us
      redirects:
        - scheme https code 301  if !is_ssl !host_conncheck !host_mirrorcache_us
        - code 301 prefix https://www.opensuse.org if host_mainpage !path_matrix_client !path_matrix_federation

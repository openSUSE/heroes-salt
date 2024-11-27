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

        - host_conncheck         hdr(host)   -i conncheck.opensuse.org
        - host_mainpage          hdr(host)   -i opensuse.org
        - host_mirrorcache_us    hdr(host)   -i mirrorcache-us.opensuse.org
        - host_provo_dlc         hdr(host)   -i provo-downloadcontent.opensuse.org
        - host_provo_mirror      hdr(host)   -i provo-mirror.opensuse.org
        - host_slc_dlc           hdr(host)   -i slc-downloadcontent.opensuse.org
        - host_slc_mirror        hdr(host)   -i slc-mirror.opensuse.org
        - host_static            hdr(host)   -i static.opensuse.org
        - host_static            hdr(host)   -i www.opensuse.org

      default_backend: maintenance
      use_backends:
        - error_403              if path_dot_scm
        - matrix-client          if path_matrix_client
        - matrix-federation      if path_matrix_federation
        - security_txt           if path_security

        - conncheck              if host_conncheck
        - mirror                 if host_slc_dlc || host_slc_mirror
        - mirrorcache            if host_mirrorcache_us
        - static                 if host_static
      redirects:
        - scheme https code 301  if !is_ssl !host_conncheck !host_mirrorcache_us
        - code 301 prefix https://www.opensuse.org if host_mainpage !path_matrix_client !path_matrix_federation
        - code 301 prefix https://slc-downloadcontent.opensuse.org if host_provo_dlc
        - code 301 prefix https://slc-mirror.opensuse.org if host_provo_mirror

    rsync:
      acls:
        - net_obs src 195.135.223.32/29

      default_backend: mirror-rsync
      use_backends:
        - mirror-rsync-push if net_obs

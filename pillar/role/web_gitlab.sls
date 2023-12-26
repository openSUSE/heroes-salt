include:
  - role.common.nginx
  {% if salt['grains.get']('include_secrets', True) %}
  - secrets.role.web_gitlab
  {% endif %}

nginx:
  ng:
    certificates:
      gitlab.infra.opensuse.org:
        public_cert: |
          -----BEGIN CERTIFICATE-----
          MIIEWTCCA0GgAwIBAgIBDDANBgkqhkiG9w0BAQsFADA9MRswGQYDVQQKDBJJTkZS
          QS5PUEVOU1VTRS5PUkcxHjAcBgNVBAMMFUNlcnRpZmljYXRlIEF1dGhvcml0eTAe
          Fw0xNzEwMTkxMjI5MzVaFw0xOTEwMjAxMjI5MzVaMEExGzAZBgNVBAoMEklORlJB
          Lk9QRU5TVVNFLk9SRzEiMCAGA1UEAwwZZ2l0bGFiLmluZnJhLm9wZW5zdXNlLm9y
          ZzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALWfuMhdJOdrwvu2hCw0
          +bRNl8AADSvdBBokQlwpUvbgITNWR3tkj/KgIEO0ohBC7j+a2L3t3qm5tP8ETdET
          cS96lj1nZ6fTWV1J9qezfpTBRDE3VIK3vykoBqzRMBVq6R4Kajg7SvB9pWRpHBC4
          xm3vPA4AnSN9skPtMMGpqZxFMbpGsirObzr5Rit4tM53gZy7zgS2n22TqMeEsEYv
          d/fHxW2bNLvS5BwX+RU1NhRlNFDPI7BQgCOGzgWrKZeukGfzcOhIXMKtnLPQc/65
          VcGQDRm01ReSBqNbyADuAfbYrFOPyf8V2FlloUG/voM4c5y6WamHv2ZJepel5qxI
          ickCAwEAAaOCAV4wggFaMB8GA1UdIwQYMBaAFKlSimqonCWUWJHsFYnI+g8qlmg/
          MEQGCCsGAQUFBwEBBDgwNjA0BggrBgEFBQcwAYYoaHR0cDovL2lwYS1jYS5pbmZy
          YS5vcGVuc3VzZS5vcmcvY2Evb2NzcDAOBgNVHQ8BAf8EBAMCBPAwHQYDVR0lBBYw
          FAYIKwYBBQUHAwEGCCsGAQUFBwMCMH0GA1UdHwR2MHQwcqA6oDiGNmh0dHA6Ly9p
          cGEtY2EuaW5mcmEub3BlbnN1c2Uub3JnL2lwYS9jcmwvTWFzdGVyQ1JMLmJpbqI0
          pDIwMDEOMAwGA1UECgwFaXBhY2ExHjAcBgNVBAMMFUNlcnRpZmljYXRlIEF1dGhv
          cml0eTAdBgNVHQ4EFgQUrqKLD5dYozCI//zl7UW5jYyEkXIwJAYDVR0RBB0wG4IZ
          Z2l0bGFiLmluZnJhLm9wZW5zdXNlLm9yZzANBgkqhkiG9w0BAQsFAAOCAQEAVm3I
          IpSAJovwTDnbDebdPl0+o9QKCYN91B6HXcet05Z+8endi2Nk/vWsa3pClmfo4hgv
          GieObg+fOnjL7JuPXUDf/0/WggaIjGEbk7I8CUubjK3u6AxM2csWBqg0XEL9KdT9
          ScNcNVzHqhrIgO2pz2xImVO03hSLnmsVjTl/ssOsSBbWYSHueT3C7ZJIr4gQ7XDI
          wL0yxP6NShgkEqAUs9QY5GBjm5bsykOj89qgi6Zu8kUJqPYLKkwjZy62cDRvoiQh
          TM0JvF2fa2AjvK0CYcYkIo+Kz1KagM52oQBlZQO7RcEVcW9GfHVMmmj3in5/U45H
          nLpMhv4+wJAh8gJ0oA==
          -----END CERTIFICATE-----
        # private_key included from pillar/secrets/role/web_gitlab.sls
    dh_param:
      gitlab.infra.opensuse.org.dhparams: |
        -----BEGIN DH PARAMETERS-----
        MIIBCAKCAQEA7PJQ8wuX4X5olj1lgscd7NWYCdW2+W/8JmBYQE79qnjKhW9I0lg6
        zigDe6qUh/QonJ9v2rjeoOMa9lFpgee7Hd4QP1ZmS2seaNBVaVBUWaTX/W8Kzi6B
        muks7dMjbkrx4hHzw5A/UK4sXR7o2jkZbSF72hrxL9e2EAD0DTH3cyVJnjbbjxC/
        G44CZVTNZpPk1J9kl00eq19Nx/0tXoa6mS1I4h6+zHS8mg2rZKwWZ+FbpGunGXmE
        V5EOx0TUmcFmCxpdS94+PnFrS78OKpMugJWQNE4hLwZ19+HTzFKRHSoGTUXOZrOk
        QwknZM+Uol0R0oUeo/5zEmN4mfQ1Iv0nCwIBAg==
        -----END DH PARAMETERS-----
    servers:
      managed:
        gitlab.infra.opensuse.org.conf:
          ## Modified from http://blog.phusion.nl/2012/04/21/tutorial-setting-up-gitlab-on-debian-6/
          ## Modified from https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
          ## Modified from https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
          config:
            - upstream gitlab:
                - server:
                    - unix:/srv/www/vhosts/gitlab-ce/tmp/sockets/gitlab.socket
                    - fail_timeout=0
            - upstream gitlab-workhorse:
                - server:
                    - unix:/srv/www/vhosts/gitlab-ce/tmp/sockets/gitlab-workhorse.socket
                    - fail_timeout=0
            - map $http_upgrade $connection_upgrade_gitlab_ssl:
                - default: upgrade
                - "''": close
            ## NGINX 'combined' log format with filtered query strings
            - log_format: gitlab_ssl_access $remote_addr - $remote_user [$time_local] "$request_method $gitlab_ssl_filtered_request_uri $server_protocol" $status $body_bytes_sent "$gitlab_ssl_filtered_http_referer" "$http_user_agent"
            ## Remove private_token from the request URI
            # In:  /foo?private_token=unfiltered&authenticity_token=unfiltered&rss_token=unfiltered&...
            # Out: /foo?private_token=[FILTERED]&authenticity_token=unfiltered&rss_token=unfiltered&...
            - map $request_uri $gitlab_ssl_temp_request_uri_1:
                - default: $request_uri
                - ~(?i)^(?<start>.*)(?<temp>[\?&]private[\-_]token)=[^&]*(?<rest>.*)$: '"$start$temp=[FILTERED]$rest"'
            ## Remove authenticity_token from the request URI
            # In:  /foo?private_token=[FILTERED]&authenticity_token=unfiltered&rss_token=unfiltered&...
            # Out: /foo?private_token=[FILTERED]&authenticity_token=[FILTERED]&rss_token=unfiltered&...
            - map $gitlab_ssl_temp_request_uri_1 $gitlab_ssl_temp_request_uri_2:
                - default: $gitlab_ssl_temp_request_uri_1
                - ~(?i)^(?<start>.*)(?<temp>[\?&]authenticity[\-_]token)=[^&]*(?<rest>.*)$: '"$start$temp=[FILTERED]$rest"'
            ## Remove rss_token from the request URI
            # In:  /foo?private_token=[FILTERED]&authenticity_token=[FILTERED]&rss_token=unfiltered&...
            # Out: /foo?private_token=[FILTERED]&authenticity_token=[FILTERED]&rss_token=[FILTERED]&...
            - map $gitlab_ssl_temp_request_uri_2 $gitlab_ssl_filtered_request_uri:
                - default: $gitlab_ssl_temp_request_uri_2
                - ~(?i)^(?<start>.*)(?<temp>[\?&]rss[\-_]token)=[^&]*(?<rest>.*)$: '"$start$temp=[FILTERED]$rest"'
            ## A version of the referer without the query string
            - map $http_referer $gitlab_ssl_filtered_http_referer:
                - default: $http_referer
                - ~^(?<temp>.*)\?: $temp
            ## Redirects all HTTP traffic to the HTTPS host
            - server:
                - listen:
                    - "[::]:80"
                    - ipv6only=on
                    - default_server
                - server_name: gitlab.infra.opensuse.org
                - server_tokens: 'off'
                - return 301: https://$http_host$request_uri
                - access_log:
                    - /var/log/nginx/gitlab_access.log
                    - gitlab_ssl_access
                - error_log: /var/log/nginx/gitlab_error.log
            - server:
                - listen:
                    - "[::]:443"
                    - ipv6only=on
                    - ssl
                    - default_server
                - server_name: gitlab.infra.opensuse.org
                - server_tokens: 'off'
                ## Strong SSL Security
                ## https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html & https://cipherli.st/
                - ssl_certificate: /etc/nginx/ssl/gitlab.infra.opensuse.org.crt
                - ssl_certificate_key: /etc/nginx/ssl/gitlab.infra.opensuse.org.key
                # GitLab needs backwards compatible ciphers to retain compatibility with Java IDEs
                - ssl_ciphers: '"ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4"'
                - ssl_protocols:
                    - TLSv1
                    - TLSv1.1
                    - TLSv1.2
                - ssl_prefer_server_ciphers: 'on'
                - ssl_session_cache: shared:SSL:10m
                - ssl_session_timeout: 5m
                - ssl_dhparam: /etc/nginx/ssl/gitlab.infra.opensuse.org.dhparams
                ## [Optional] Enable HTTP Strict Transport Security
                - add_header: Strict-Transport-Security "max-age=31536000; includeSubDomains"
                - access_log:
                    - /var/log/nginx/gitlab_access.log
                    - gitlab_ssl_access
                - error_log: /var/log/nginx/gitlab_error.log
                - location /:
                    - client_max_body_size: 0
                    - gzip: 'off'
                    ## https://github.com/gitlabhq/gitlabhq/issues/694
                    ## Some requests take more than 30 seconds.
                    - proxy_read_timeout: 300
                    - proxy_connect_timeout: 300
                    - proxy_redirect: 'off'
                    - proxy_http_version: 1.1
                    - proxy_set_header: Host $http_host
                    - proxy_set_header: X-Real-IP $remote_addr
                    - proxy_set_header: X-Forwarded-Ssl on
                    - proxy_set_header: X-Forwarded-For $proxy_add_x_forwarded_for
                    - proxy_set_header: X-Forwarded-Proto $scheme
                    - proxy_set_header: Upgrade $http_upgrade
                    - proxy_set_header: Connection $connection_upgrade_gitlab_ssl
                    - proxy_pass: http://gitlab-workhorse
                    # display .txt job artifacts in the browser instead of downloading them
                    # without the need for GitLab pages
                    - location ~ .*\/raw\/(.*\.txt)$:
                        - proxy_hide_header: Content-Disposition
                        - proxy_hide_header: Content-Type
                        - access_log: /var/log/nginx/gitlab_txt_access.log
                        - add_header: >-
                            Content-Disposition 'inline; "filename=$1"'
                        - add_header: Content-Type text/plain
                        - proxy_pass: http://gitlab-workhorse
                    # display said artifacts immediately instead of having the user go through the "download instead" page
                    - location ~ .*\/file\/(.*\.txt)$:
                        - rewrite: ^(.*)/file/(.*)$ $1/raw/$2
                - error_page: 404 /404.html
                - error_page: 422 /422.html
                - error_page: 500 /500.html
                - error_page: 502 /502.html
                - error_page: 503 /503.html
                - location ~ ^/(404|422|500|502|503)\.html$:
                    - root: /srv/www/vhosts/gitlab-ce/public
                    - internal
          enabled: True
profile:
  web:
    server:
      nginx:
        csr:
          gitlab.infra.opensuse.org: |
            -----BEGIN CERTIFICATE REQUEST-----
            MIIDGzCCAgMCAQAwgZ4xCzAJBgNVBAYTAkRFMRAwDgYDVQQIDAdCYXZhcmlhMRIw
            EAYDVQQHDAlOdXJlbWJlcmcxETAPBgNVBAoMCG9wZW5TVVNFMQ8wDQYDVQQLDAZI
            ZXJvZXMxIjAgBgNVBAMMGWdpdGxhYi5pbmZyYS5vcGVuc3VzZS5vcmcxITAfBgkq
            hkiG9w0BCQEWEmFkbWluQG9wZW5zdXNlLm9yZzCCASIwDQYJKoZIhvcNAQEBBQAD
            ggEPADCCAQoCggEBALWfuMhdJOdrwvu2hCw0+bRNl8AADSvdBBokQlwpUvbgITNW
            R3tkj/KgIEO0ohBC7j+a2L3t3qm5tP8ETdETcS96lj1nZ6fTWV1J9qezfpTBRDE3
            VIK3vykoBqzRMBVq6R4Kajg7SvB9pWRpHBC4xm3vPA4AnSN9skPtMMGpqZxFMbpG
            sirObzr5Rit4tM53gZy7zgS2n22TqMeEsEYvd/fHxW2bNLvS5BwX+RU1NhRlNFDP
            I7BQgCOGzgWrKZeukGfzcOhIXMKtnLPQc/65VcGQDRm01ReSBqNbyADuAfbYrFOP
            yf8V2FlloUG/voM4c5y6WamHv2ZJepel5qxIickCAwEAAaA3MDUGCSqGSIb3DQEJ
            DjEoMCYwJAYDVR0RBB0wG4IZZ2l0bGFiLmluZnJhLm9wZW5zdXNlLm9yZzANBgkq
            hkiG9w0BAQsFAAOCAQEAGJ+RU/bwMTZ+/rkCibJD3Ylp+UUBm0qvFTFkEtkptrM2
            5/im/ogEPgYZnJNBlU+lTba7XL3uyG+eX3A3n8aX9wJE7DMYB7x1qZGkUppd0zIG
            myRBZlZUBxtGtOLGW5+AcpjHdqk5aeLjaWz3PaX3WD7QnAYx7XWPJMdcFVzzwPoO
            M+mSd9H9RUx9HOYy2Wolxg+Mx05mvBrTHoTYsgSBhrmSNLVbA7ZgvAx+cc4vh9Q0
            6NaN7mDmnbT1CVSlQ43o0pRpUIwa9NGD7DQ/Ccrw0FevD/7szXa9KZvXhHdqS7BP
            PJKOVLf4VbNDRGmkks0fst/NNdNuXRlS4lZMePi6pQ==
            -----END CERTIFICATE REQUEST-----

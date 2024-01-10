include:
  - role.common.nginx
  {% if salt['grains.get']('include_secrets', True) %}
  - secrets.role.web_gitlab
  {% endif %}

nginx:
  certificates:
    gitlab.infra.opensuse.org:
      public_cert: |
        -----BEGIN CERTIFICATE-----
        MIICizCCAjKgAwIBAgIQYFYplMcg9h1T8yhiHMIsszAKBggqhkjOPQQDAjBKMRsw
        GQYDVQQKExJIZXJvZXMgaW50ZXJuYWwgQ0ExKzApBgNVBAMTIkhlcm9lcyBpbnRl
        cm5hbCBDQSBJbnRlcm1lZGlhdGUgQ0EwHhcNMjMxMjI2MTQ0NzUyWhcNMjQxMjI1
        MTQ0NzUxWjAkMSIwIAYDVQQDExlnaXRsYWIuaW5mcmEub3BlbnN1c2Uub3JnMIGb
        MBAGByqGSM49AgEGBSuBBAAjA4GGAAQB13oP2JI/k/0zEBClt18ZfJn9wuYNXY6y
        kMGJePdu7SyidJ0fEZgyjiMEu9AIaWQRUcHsEpsH1IopluOm1wzsu3cAuztE5esp
        GNDLHqs1hSU/Vt49exZdpc4jnjRro379iu4oCTJEpAGlmgStM45zWki5HUwiFe3O
        Y+6ltNma6NqWQhCjgdwwgdkwDgYDVR0PAQH/BAQDAgeAMB0GA1UdJQQWMBQGCCsG
        AQUFBwMBBggrBgEFBQcDAjAdBgNVHQ4EFgQUxxJ///3vhHrofS3YLRp/7zMzpiAw
        HwYDVR0jBBgwFoAU6nbAOLNZKEWtchF/2j1cLSmoZmQwaAYDVR0RBGEwX4IZZ2l0
        bGFiLmluZnJhLm9wZW5zdXNlLm9yZ4IfZ2l0bGFiLXBhZ2VzLmluZnJhLm9wZW5z
        dXNlLm9yZ4IhKi5naXRsYWItcGFnZXMuaW5mcmEub3BlbnN1c2Uub3JnMAoGCCqG
        SM49BAMCA0cAMEQCIDMkQ7oMN45LNEl1cijWtihP3VsjHhoPO6Ap2brOFlhvAiAn
        cbqJ0ylLu44GeKC4+YMONT6CYP0+mr373QK+Ffg2qw==
        -----END CERTIFICATE-----
        -----BEGIN CERTIFICATE-----
        MIIB8TCCAZegAwIBAgIRAKUPy6g1pK/iPT3xlHXD4SUwCgYIKoZIzj0EAwIwQjEb
        MBkGA1UEChMSSGVyb2VzIGludGVybmFsIENBMSMwIQYDVQQDExpIZXJvZXMgaW50
        ZXJuYWwgQ0EgUm9vdCBDQTAeFw0yMTAzMjYxNDU2MzBaFw0zMTAzMjQxNDU2MzBa
        MEoxGzAZBgNVBAoTEkhlcm9lcyBpbnRlcm5hbCBDQTErMCkGA1UEAxMiSGVyb2Vz
        IGludGVybmFsIENBIEludGVybWVkaWF0ZSBDQTBZMBMGByqGSM49AgEGCCqGSM49
        AwEHA0IABCjVMdnPT83h/pbT+p0RftUhOgAa/6kUfds/KQqpHWfSeGUC1q63uqMt
        zJEY7ayXiclvN2q5Pp7tb48ij1BBjyqjZjBkMA4GA1UdDwEB/wQEAwIBBjASBgNV
        HRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBTqdsA4s1koRa1yEX/aPVwtKahmZDAf
        BgNVHSMEGDAWgBTcDTCZTLQozqIWRXU9drYriGctSzAKBggqhkjOPQQDAgNIADBF
        AiEAn+Tkp4uD38dYq0zGCJ6RYk/zFSrsZYYbGdbn3qMQRKUCIEJiKrMy36hfcHKT
        ryjDcdoH37uPupe6AcZTMWX/6kne
        -----END CERTIFICATE-----
      # private_key included from pillar/secrets/role/web_gitlab.sls
  servers:
    managed:
      gitlab.infra.opensuse.org.conf:
        config:
          - upstream gitlab:
              - server: unix:/srv/www/vhosts/gitlab-ce/tmp/sockets/gitlab.socket fail_timeout=0
          - upstream gitlab-workhorse:
              - server: unix:/srv/www/vhosts/gitlab-ce/tmp/sockets/gitlab-workhorse.socket fail_timeout=0
          - map $http_upgrade $connection_upgrade_gitlab_ssl:
              - default: upgrade
              - "''": close
          ## NGINX 'combined' log format with filtered query strings
          - log_format: >-
              gitlab_ssl_access
              '$remote_addr - $remote_user [$time_local] "$request_method $gitlab_ssl_filtered_request_uri
              $server_protocol" $status $body_bytes_sent "$gitlab_ssl_filtered_http_referer" "$http_user_agent"'
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
              - ~(?i)^(?<start>.*)(?<temp>[\?&]feed[\-_]token)=[^&]*(?<rest>.*)$: '"$start$temp=[FILTERED]$rest"'
          ## A version of the referer without the query string
          - map $http_referer $gitlab_ssl_filtered_http_referer:
              - default: $http_referer
              - ~^(?<temp>.*)\?: $temp
          ## Redirects all HTTP traffic to the HTTPS host
          - server:
              - listen: '[::]:80 ipv6only=on default_server'
              - server_name: gitlab.infra.opensuse.org
              - server_tokens: 'off'
              - include: acme-challenge
              - location /:
                  - return 301: https://$http_host$request_uri
              - access_log: /var/log/nginx/gitlab_access.log gitlab_ssl_access
              - error_log: /var/log/nginx/gitlab_error.log
          - server:
              - listen: '[::]:443 ipv6only=on ssl default_server'
              - server_name: gitlab.infra.opensuse.org
              - server_tokens: 'off'
              ## Strong SSL Security
              ## https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html & https://cipherli.st/
              - ssl_certificate: /etc/nginx/ssl/gitlab.infra.opensuse.org.crt
              - ssl_certificate_key: /etc/nginx/ssl/gitlab.infra.opensuse.org.key
              # GitLab needs backwards compatible ciphers to retain compatibility with Java IDEs
              - ssl_ciphers: >-  # noqa 204
                  'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384'
              - ssl_protocols:
                  - TLSv1.3
              - ssl_prefer_server_ciphers: 'off'
              - ssl_session_cache: shared:SSL:10m
              - ssl_session_timeout: 1d
              ## [Optional] Enable HTTP Strict Transport Security
              - add_header: Strict-Transport-Security "max-age=31536000; includeSubDomains"
              - access_log: /var/log/nginx/gitlab_access.log gitlab_ssl_access
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

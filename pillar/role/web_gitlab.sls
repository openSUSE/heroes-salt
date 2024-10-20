include:
  - role.common.nginx

nginx:
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
              - ssl_certificate: /etc/ssl/services/git.infra.opensuse.org/fullchain.pem
              - ssl_certificate_key: /etc/ssl/services/git.infra.opensuse.org/privkey.pem
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

sshd_config:
  matches:
    gitlab:
      type:
        User: git
      options:
        AuthorizedKeysCommand: /usr/lib/gitlab/shell/bin/gitlab-shell-authorized-keys-check gitlab %u %k
        AuthorizedKeysCommandUser: gitlab

include:
  - role.common.nginx
  - secrets.role.web_gitlab

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
                - listen: 0.0.0.0:80
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
                    - 0.0.0.0:443
                    - ssl
                - listen:
                    - "[::]:443"
                    - ipv6only=on
                    - ssl
                    - default_server
                - server_name: gitlab.infra.opensuse.org
                - server_tokens: 'off'
                ## Strong SSL Security
                ## https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html & https://cipherli.st/
                - ssl: 'on'
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
  {% set osrelease = salt['grains.get']('osrelease') %}
  {% if osrelease == '42.3' %}
  monitoring:
    check_zypper:
      whitelist:
        - gitaly
        - gitlab-ce
        - gitlab-common
        - gitlab-pages
        - gitlab-shell
        - gitlab-workhorse
        - grpc
        - libgrpc4
        - libprotobuf15
        - libprotoc15
        - libruby2_4-2_4
        - nodejs8
        - ruby2.4
        - ruby2.4-rubygem-RedCloth
        - ruby2.4-rubygem-ace-rails-ap
        - ruby2.4-rubygem-actionmailer-4_2
        - ruby2.4-rubygem-actionpack-4_2
        - ruby2.4-rubygem-actionview-4_2
        - ruby2.4-rubygem-activejob-4_2
        - ruby2.4-rubygem-activemodel-4_2
        - ruby2.4-rubygem-activerecord-4_2
        - ruby2.4-rubygem-activesupport-4_2
        - ruby2.4-rubygem-acts-as-taggable-on
        - ruby2.4-rubygem-addressable
        - ruby2.4-rubygem-akismet
        - ruby2.4-rubygem-allocations
        - ruby2.4-rubygem-arel-6
        - ruby2.4-rubygem-asana
        - ruby2.4-rubygem-asciidoctor
        - ruby2.4-rubygem-asciidoctor-plantuml
        - ruby2.4-rubygem-attr_encrypted
        - ruby2.4-rubygem-attr_required
        - ruby2.4-rubygem-autoprefixer-rails
        - ruby2.4-rubygem-babosa
        - ruby2.4-rubygem-base32
        - ruby2.4-rubygem-batch-loader
        - ruby2.4-rubygem-bcrypt_pbkdf
        - ruby2.4-rubygem-bindata
        - ruby2.4-rubygem-bootstrap_form
        - ruby2.4-rubygem-browser
        - ruby2.4-rubygem-builder
        - ruby2.4-rubygem-bundler
        - ruby2.4-rubygem-carrierwave
        - ruby2.4-rubygem-cause
        - ruby2.4-rubygem-charlock_holmes
        - ruby2.4-rubygem-chronic
        - ruby2.4-rubygem-chronic_duration
        - ruby2.4-rubygem-chunky_png
        - ruby2.4-rubygem-citrus
        - ruby2.4-rubygem-concurrent-ruby
        - ruby2.4-rubygem-concurrent-ruby-ext
        - ruby2.4-rubygem-connection_pool
        - ruby2.4-rubygem-crack
        - ruby2.4-rubygem-crass
        - ruby2.4-rubygem-creole
        - ruby2.4-rubygem-css_parser
        - ruby2.4-rubygem-d3_rails
        - ruby2.4-rubygem-debugger-ruby_core_source
        - ruby2.4-rubygem-deckar01-task_list
        - ruby2.4-rubygem-declarative
        - ruby2.4-rubygem-declarative-option
        - ruby2.4-rubygem-default_value_for
        - ruby2.4-rubygem-devise
        - ruby2.4-rubygem-devise-two-factor
        - ruby2.4-rubygem-diff-lcs
        - ruby2.4-rubygem-diffy
        - ruby2.4-rubygem-domain_name
        - ruby2.4-rubygem-doorkeeper
        - ruby2.4-rubygem-doorkeeper-openid_connect
        - ruby2.4-rubygem-dropzonejs-rails
        - ruby2.4-rubygem-email_reply_trimmer
        - ruby2.4-rubygem-encryptor
        - ruby2.4-rubygem-escape_utils
        - ruby2.4-rubygem-et-orbi
        - ruby2.4-rubygem-excon
        - ruby2.4-rubygem-execjs
        - ruby2.4-rubygem-expression_parser
        - ruby2.4-rubygem-faraday
        - ruby2.4-rubygem-faraday-0.8
        - ruby2.4-rubygem-faraday_middleware
        - ruby2.4-rubygem-fast_gettext
        - ruby2.4-rubygem-ffi
        - ruby2.4-rubygem-flipper
        - ruby2.4-rubygem-flipper-active_record
        - ruby2.4-rubygem-flowdock
        - ruby2.4-rubygem-fog-aliyun
        - ruby2.4-rubygem-fog-aws
        - ruby2.4-rubygem-fog-core
        - ruby2.4-rubygem-fog-google
        - ruby2.4-rubygem-fog-json
        - ruby2.4-rubygem-fog-local
        - ruby2.4-rubygem-fog-openstack
        - ruby2.4-rubygem-fog-rackspace
        - ruby2.4-rubygem-fog-xml
        - ruby2.4-rubygem-font-awesome-rails
        - ruby2.4-rubygem-formatador
        - ruby2.4-rubygem-gemnasium-gitlab-service
        - ruby2.4-rubygem-gemojione
        - ruby2.4-rubygem-gettext
        - ruby2.4-rubygem-gettext_i18n_rails
        - ruby2.4-rubygem-gettext_i18n_rails_js
        - ruby2.4-rubygem-gitaly-proto
        - ruby2.4-rubygem-github-linguist
        - ruby2.4-rubygem-github-markup
        - ruby2.4-rubygem-gitlab-flowdock-git-hook
        - ruby2.4-rubygem-gitlab-grit
        - ruby2.4-rubygem-gitlab-markup
        - ruby2.4-rubygem-gitlab_omniauth-ldap
        - ruby2.4-rubygem-globalid
        - ruby2.4-rubygem-gollum-grit_adapter
        - ruby2.4-rubygem-gollum-lib
        - ruby2.4-rubygem-gollum-rugged_adapter
        - ruby2.4-rubygem-gon
        - ruby2.4-rubygem-google-api-client
        - ruby2.4-rubygem-google-protobuf
        - ruby2.4-rubygem-googleapis-common-protos-types
        - ruby2.4-rubygem-googleauth
        - ruby2.4-rubygem-gpgme
        - ruby2.4-rubygem-grape
        - ruby2.4-rubygem-grape-entity
        - ruby2.4-rubygem-grape-route-helpers
        - ruby2.4-rubygem-grape_logging
        - ruby2.4-rubygem-grpc
        - ruby2.4-rubygem-hamlit
        - ruby2.4-rubygem-hashie
        - ruby2.4-rubygem-hashie-forbidden_attributes
        - ruby2.4-rubygem-health_check
        - ruby2.4-rubygem-hipchat
        - ruby2.4-rubygem-html-pipeline
        - ruby2.4-rubygem-html2text
        - ruby2.4-rubygem-htmlentities
        - ruby2.4-rubygem-http-0.9
        - ruby2.4-rubygem-http-cookie
        - ruby2.4-rubygem-http-form_data
        - ruby2.4-rubygem-httparty
        - ruby2.4-rubygem-httpclient
        - ruby2.4-rubygem-i18n
        - ruby2.4-rubygem-ice_nine
        - ruby2.4-rubygem-influxdb
        - ruby2.4-rubygem-ipaddress
        - ruby2.4-rubygem-jira-ruby
        - ruby2.4-rubygem-jquery-atwho-rails
        - ruby2.4-rubygem-jquery-rails
        - ruby2.4-rubygem-json-1
        - ruby2.4-rubygem-json-jwt
        - ruby2.4-rubygem-jwt
        - ruby2.4-rubygem-kaminari
        - ruby2.4-rubygem-kaminari-actionview
        - ruby2.4-rubygem-kaminari-activerecord
        - ruby2.4-rubygem-kaminari-core
        - ruby2.4-rubygem-kgio
        - ruby2.4-rubygem-kubeclient
        - ruby2.4-rubygem-licensee
        - ruby2.4-rubygem-little-plugger
        - ruby2.4-rubygem-logging
        - ruby2.4-rubygem-lograge
        - ruby2.4-rubygem-loofah
        - ruby2.4-rubygem-mail
        - ruby2.4-rubygem-mail_room
        - ruby2.4-rubygem-memoist
        - ruby2.4-rubygem-method_source
        - ruby2.4-rubygem-mime-types
        - ruby2.4-rubygem-mini_mime
        - ruby2.4-rubygem-mini_portile2
        - ruby2.4-rubygem-mousetrap-rails
        - ruby2.4-rubygem-multi_json
        - ruby2.4-rubygem-multi_xml
        - ruby2.4-rubygem-multipart-post-1.2
        - ruby2.4-rubygem-mustermann
        - ruby2.4-rubygem-mustermann-grape
        - ruby2.4-rubygem-net-ldap
        - ruby2.4-rubygem-net-ssh
        - ruby2.4-rubygem-netrc
        - ruby2.4-rubygem-nokogiri
        - ruby2.4-rubygem-numerizer
        - ruby2.4-rubygem-oauth
        - ruby2.4-rubygem-oauth2
        - ruby2.4-rubygem-octokit
        - ruby2.4-rubygem-oj
        - ruby2.4-rubygem-omniauth
        - ruby2.4-rubygem-omniauth-auth0
        - ruby2.4-rubygem-omniauth-authentiq
        - ruby2.4-rubygem-omniauth-azure-oauth2
        - ruby2.4-rubygem-omniauth-cas3
        - ruby2.4-rubygem-omniauth-facebook
        - ruby2.4-rubygem-omniauth-github
        - ruby2.4-rubygem-omniauth-gitlab
        - ruby2.4-rubygem-omniauth-google-oauth2
        - ruby2.4-rubygem-omniauth-kerberos
        - ruby2.4-rubygem-omniauth-multipassword
        - ruby2.4-rubygem-omniauth-oauth
        - ruby2.4-rubygem-omniauth-oauth2
        - ruby2.4-rubygem-omniauth-oauth2-generic
        - ruby2.4-rubygem-omniauth-saml
        - ruby2.4-rubygem-omniauth-shibboleth
        - ruby2.4-rubygem-omniauth-twitter
        - ruby2.4-rubygem-omniauth_crowd
        - ruby2.4-rubygem-org-ruby
        - ruby2.4-rubygem-orm_adapter
        - ruby2.4-rubygem-os
        - ruby2.4-rubygem-paranoia
        - ruby2.4-rubygem-peek
        - ruby2.4-rubygem-peek-gc
        - ruby2.4-rubygem-peek-host
        - ruby2.4-rubygem-peek-performance_bar
        - ruby2.4-rubygem-peek-pg
        - ruby2.4-rubygem-peek-rblineprof
        - ruby2.4-rubygem-peek-redis
        - ruby2.4-rubygem-peek-sidekiq
        - ruby2.4-rubygem-pg
        - ruby2.4-rubygem-po_to_json
        - ruby2.4-rubygem-posix-spawn
        - ruby2.4-rubygem-premailer
        - ruby2.4-rubygem-premailer-rails
        - ruby2.4-rubygem-prometheus-client-mmap
        - ruby2.4-rubygem-public_suffix
        - ruby2.4-rubygem-puma
        - ruby2.4-rubygem-puma_worker_killer
        - ruby2.4-rubygem-pyu-ruby-sasl
        - ruby2.4-rubygem-rack-1_6
        - ruby2.4-rubygem-rack-accept
        - ruby2.4-rubygem-rack-attack
        - ruby2.4-rubygem-rack-cors
        - ruby2.4-rubygem-rack-oauth2
        - ruby2.4-rubygem-rack-protection
        - ruby2.4-rubygem-rack-proxy
        - ruby2.4-rubygem-rails-4_2
        - ruby2.4-rubygem-rails-dom-testing-1
        - ruby2.4-rubygem-rails-html-sanitizer
        - ruby2.4-rubygem-rails-i18n-4
        - ruby2.4-rubygem-railties-4_2
        - ruby2.4-rubygem-rainbow
        - ruby2.4-rubygem-raindrops
        - ruby2.4-rubygem-rake
        - ruby2.4-rubygem-rb-fsevent
        - ruby2.4-rubygem-rb-inotify
        - ruby2.4-rubygem-rblineprof
        - ruby2.4-rubygem-rbnacl
        - ruby2.4-rubygem-re2
        - ruby2.4-rubygem-recaptcha
        - ruby2.4-rubygem-recursive-open-struct
        - ruby2.4-rubygem-redcarpet
        - ruby2.4-rubygem-redis-3
        - ruby2.4-rubygem-redis-actionpack
        - ruby2.4-rubygem-redis-activesupport
        - ruby2.4-rubygem-redis-namespace
        - ruby2.4-rubygem-redis-rack
        - ruby2.4-rubygem-redis-rails
        - ruby2.4-rubygem-redis-store
        - ruby2.4-rubygem-representable
        - ruby2.4-rubygem-request_store
        - ruby2.4-rubygem-responders
        - ruby2.4-rubygem-rest-client
        - ruby2.4-rubygem-retriable
        - ruby2.4-rubygem-rinku
        - ruby2.4-rubygem-rotp
        - ruby2.4-rubygem-rouge
        - ruby2.4-rubygem-rqrcode
        - ruby2.4-rubygem-rqrcode-rails3
        - ruby2.4-rubygem-ruby-fogbugz
        - ruby2.4-rubygem-ruby-prof
        - ruby2.4-rubygem-ruby-saml
        - ruby2.4-rubygem-ruby_parser
        - ruby2.4-rubygem-rubyntlm
        - ruby2.4-rubygem-rubypants
        - ruby2.4-rubygem-rufus-scheduler
        - ruby2.4-rubygem-rugged
        - ruby2.4-rubygem-sanitize-2.1
        - ruby2.4-rubygem-sass
        - ruby2.4-rubygem-sass-listen
        - ruby2.4-rubygem-sass-rails-5_0
        - ruby2.4-rubygem-sawyer
        - ruby2.4-rubygem-securecompare
        - ruby2.4-rubygem-seed-fu
        - ruby2.4-rubygem-select2-rails
        - ruby2.4-rubygem-sentry-raven
        - ruby2.4-rubygem-settingslogic
        - ruby2.4-rubygem-sexp_processor
        - ruby2.4-rubygem-sidekiq
        - ruby2.4-rubygem-sidekiq-cron
        - ruby2.4-rubygem-sidekiq-limit_fetch
        - ruby2.4-rubygem-signet
        - ruby2.4-rubygem-slack-notifier
        - ruby2.4-rubygem-sprockets
        - ruby2.4-rubygem-sprockets-rails
        - ruby2.4-rubygem-state_machines
        - ruby2.4-rubygem-state_machines-activemodel
        - ruby2.4-rubygem-state_machines-activerecord
        - ruby2.4-rubygem-stringex
        - ruby2.4-rubygem-sys-filesystem
        - ruby2.4-rubygem-temple
        - ruby2.4-rubygem-thor
        - ruby2.4-rubygem-thread_safe
        - ruby2.4-rubygem-tilt
        - ruby2.4-rubygem-timfel-krb5-auth
        - ruby2.4-rubygem-toml-rb
        - ruby2.4-rubygem-truncato
        - ruby2.4-rubygem-tzinfo
        - ruby2.4-rubygem-u2f
        - ruby2.4-rubygem-uber
        - ruby2.4-rubygem-uglifier
        - ruby2.4-rubygem-unf
        - ruby2.4-rubygem-unf_ext
        - ruby2.4-rubygem-unicorn
        - ruby2.4-rubygem-unicorn-worker-killer
        - ruby2.4-rubygem-url_safe_base64
        - ruby2.4-rubygem-validates_hostname
        - ruby2.4-rubygem-version_sorter
        - ruby2.4-rubygem-vmstat
        - ruby2.4-rubygem-warden
        - ruby2.4-rubygem-webpack-rails
        - ruby2.4-rubygem-wikicloth
        - ruby2.4-stdlib
  {% endif %}
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

include:
  - .

nginx:
  server:
    config:
      load_module:
        - lib64/nginx/modules/ngx_http_fancyindex_module.so
  servers:
    managed:
      download:
        config:
          - server:
              - server_name: >-
                  download.infra.opensuse.org
                  download-prg.infra.opensuse.org
                  localhost
              - listen: '[::]:80 ipv6_only=on'
              - location /:
                  - root: /data/srv/www/
              - rewrite: ^/repositories/([^/]+):([^/]+)/(.*)$  /repositories/$1:/$2/$3 permanent
              - fancyindex: 'on'
              - fancyindex_name_length: 100
              - fancyindex_exact_size: 'off'
        enabled: True

zypper:
  packages:
    nginx-module-fancyindex: {}
  repositories:
    openSUSE:infrastructure:nginx-next:
      baseurl: http://download.infra.opensuse.org/repositories/openSUSE:/infrastructure:/nginx-next/$releasever/
      priority: 98
      refresh: true

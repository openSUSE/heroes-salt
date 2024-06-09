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
              - listen: '[::]:80 ipv6_only=on'
              - include:
                  - snippets/download
          - server:
              - listen: '[::]:443 ipv6only=on ssl'
              {%- set tlsdir = '/etc/ssl/services/download.infra.opensuse.org/' %}
              - ssl_certificate: {{ tlsdir }}/fullchain.pem
              - ssl_certificate_key: {{ tlsdir }}/privkey.pem
              - include:
                  - snippets/download
        enabled: True
  snippets:
    download:
      - server_name: >-
          download.infra.opensuse.org
          download-prg.infra.opensuse.org
          localhost
      - location /:
          - root: /data/srv/www/
      - rewrite: ^/repositories/([^/]+):([^/]+)/(.*)$  /repositories/$1:/$2/$3 permanent
      - fancyindex: 'on'
      - fancyindex_name_length: 100
      - fancyindex_exact_size: 'off'


zypper:
  packages:
    nginx-module-fancyindex: {}

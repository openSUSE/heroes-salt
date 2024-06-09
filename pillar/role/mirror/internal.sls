include:
  - .

nginx:
  server:
    config:
      load_module:
        - lib64/nginx/modules/ngx_http_fancyindex_module.so
  servers:
    managed:
      download.conf:
        config:
          - server:
              - listen: '[::]:80'
              - include:
                  - snippets/download
          - server:
              - listen: '[::]:443 ssl'
              - http2: ''
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
  repositories:
    openSUSE:infrastructure:nginx-next:
      baseurl: http://download.infra.opensuse.org/repositories/openSUSE:/infrastructure:/nginx-next/$releasever/
      priority: 98
      refresh: true

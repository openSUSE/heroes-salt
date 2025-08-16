include:
  - .

nginx:
  servers:
    managed:
      download.conf:
        config:
          - server:
              - listen: '[::]:80'
              - include:
                  - snippets/download
          - server:
              - listen: '[::]:443 http2 ssl'
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

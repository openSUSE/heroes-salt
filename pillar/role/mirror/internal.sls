include:
  - .
{%- if salt['grains.get']('include_secrets', True) %}
  - secrets.role.mirror.internal
{%- endif %}

mysql:
  database:
    - rmt
  user:
    rmt:
      databases:
        - database: rmt
          grants: ['all']
      host: localhost

nginx:
  servers:
    managed:
      download.conf:
        config:
          - server:
              - listen: '[::]:80'
              - include:
                  - snippets/download
              - location /repo/SUSE:
                  - include: snippets/rmt
              - location /services:
                  - include: snippets/rmt
          - server:
              - listen: '[::]:443 http2 ssl'
              {%- set tlsdir = '/etc/ssl/services/download.infra.opensuse.org/' %}
              - ssl_certificate: {{ tlsdir }}/fullchain.pem
              - ssl_certificate_key: {{ tlsdir }}/privkey.pem
              - include:
                  - snippets/download
              - location /connect:
                  - include: snippets/rmt
        enabled: True
  snippets:
    download:
      - server_name: >-
          download.infra.opensuse.org
          download-prg.infra.opensuse.org
          localhost
      - location /:
          - root: /data/repo/
          - autoindex: 'on'
      - rewrite: ^/repositories/([^/]+):([^/]+)/(.*)$  /repositories/$1:/$2/$3 permanent
    rmt:
      - proxy_pass: http://127.0.0.1  # rmt hardcodes IPv4
      - proxy_redirect: 'off'
      - proxy_read_timeout: 600
      - proxy_set_header: Host $http_host
      - proxy_set_header: X-Forwarded-Proto $scheme
      - proxy_set_header: X-Forwarded-For $proxy_add_x_forwarded_for

profile:
  rmt:
    config:
      database:
        host: localhost
        database: rmt
        username: rmt
        adapter: mysql2
        encoding: utf8
        timeout: 5000
        pool: 5
      scc:
        sync_systems: true
        metrics:
          enabled: true
          job_name: rmt
      mirroring:
        mirror_drpm: false
        mirror_src: false
        revalidate_repodata: true
        dedup_method: hardlink
      web_server:
        min_threads: 2
        max_threads: 2
        workers: 1

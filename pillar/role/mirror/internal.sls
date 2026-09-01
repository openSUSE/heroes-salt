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
          - root: /data/repo/
          - autoindex: 'on'
      - rewrite: ^/repositories/([^/]+):([^/]+)/(.*)$  /repositories/$1:/$2/$3 permanent

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

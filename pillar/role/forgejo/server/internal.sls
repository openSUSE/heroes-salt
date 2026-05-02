{%- if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.forgejo.server.internal
  - .
{%- endif %}

{%- set addr = '2a07:de40:b27e:1203::b44' %}
{%- set domain = 'git.infra.opensuse.org' %}

apparmor:
  local:
    forgejo:
      - /etc/ssl/services/{{ domain }}/{fullchain,privkey}.pem r
      - /etc/forgejo/ssh/ssh_host_{ecdsa,ed25519}_key r

profile:
  forgejo:
    server:
      branding: ioo
      # secrets are in pillar/secrets/role/forgejo/server/internal.sls
      config:
        app_name: Infra
        database:
          db_type: sqlite3
          sqlite_journal_mode: WAL
        server:
          domain: {{ domain }}
          http_addr: {{ addr }}
          cert_file: /etc/ssl/services/{{ domain }}/fullchain.pem
          key_file: /etc/ssl/services/{{ domain }}/privkey.pem
          ssh_listen_host: {{ addr }}
          ssh_server_ciphers:
            - aes256-ctr
            - aes256-gcm@openssh.com
          ssh_server_key_exchanges:
            - curve25519-sha256
            - ecdh-sha2-nistp256
            - ecdh-sha2-nistp384
            - ecdh-sha2-nistp521
          ssh_server_host_keys:
            - /etc/forgejo/ssh/ssh_host_ed25519_key
            - /etc/forgejo/ssh/ssh_host_ecdsa_key
          start_ssh_server: true
          builtin_ssh_server_user: git
        security:
          cookie_remember_name: git_ioo_remember
        cors:
          allow_domain: https://{{ domain }}
        mailer:
          from: forgejo@{{ domain }}
        session:
          cookie_name: git_ioo_session
          domain: {{ domain }}
        migrations:
          allowed_domains:
            - gitlab.infra.opensuse.org
            - code.opensuse.org
            - code.forgejo.org
            - github.com
            - api.github.com
        actions:
          default_actions_url: https://{{ domain }}
          log_retention_days: 90
          log_compression: zstd
          artifact_retention_days: 60
        log:
          level: DEBUG

{%- if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.web_progress
{%- endif %}

groups:
  redis:
    system: true
    members:
      - redmine

redis:
  redmine:
    databases: 1
    port: 0

redmine:
  plugins:
    - theme-opensuse
    - diary
    - favourite_projects
    - force-issues-private
    - login-mention-account-type
    - openid_connect
    - plugin-views-revisions
    - reopen-issues-by-mail
  config:
    configuration:
      default:
        email_delivery:
          delivery_method: :smtp
          smtp_settings:
            address: localhost
            port: 25
        attachments_storage_path: /var/lib/redmine/files
        private_by_default_projects:
          - opensuse-admin
          {#- are the ones below still used ? #}
          - opensuse-admin-cloaks
          - opensuse-board
        # secret_token -> secrets.role.web_progress
    database:
      production:
        adapter: mysql2
        database: redmine
        host: mysql.infra.opensuse.org
        port: 3307
        # username/password -> secrets.role.web_progress
        encoding: utf8mb4
        timeout: 15

profile:
  postfix:
    maincf:
      smtpd_sender_restrictions: lmdb:/etc/postfix/discard_ndrs,reject_unknown_sender_domain

zypper:
  packages:
    google-opensans-fonts: {}
  repositories:
    devel:languages:ruby:
      baseurl: https://downloadcontent.opensuse.org/repositories/devel:/languages:/ruby/$releasever/
      priority: 99
      refresh: True
    devel:languages:ruby:extensions:
      baseurl: https://downloadcontent.opensuse.org/repositories/devel:/languages:/ruby:/extensions/$releasever/
      priority: 99
      refresh: True

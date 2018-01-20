{% set host = salt['grains.get']('host') %}

keepalived:
  global_defs:
    notification_email_from: keepalived+{{ host }}@opensuse.org
    notification_email:
      - admin-auto@opensuse.org
    smtp_connect_timeout: 30
    smtp_server: relay.infra.opensuse.org

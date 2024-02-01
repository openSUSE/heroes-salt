{%- set host = salt['grains.get']('host') %}

keepalived:
  config:
    global_defs:
      notification_email_from: {{ host }}+keepalived@infra.opensuse.org
      notification_email:
        - admin-auto@opensuse.org
      smtp_connect_timeout: 30
      smtp_server: relay.infra.opensuse.org
  scripts_dir: /usr/local/libexec/keepalived

users:
  keepalived_script:
    createhome: false
    home: /var/lib/keepalived
    shell: /usr/sbin/nologin
    system: true

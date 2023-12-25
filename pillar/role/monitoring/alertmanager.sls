{%- if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.monitoring.alertmanager
{%- endif %}

profile:
  monitoring:
    prometheus:
      irc:
        irc_host: irc.ipv6.libera.chat
        irc_nickname: heroes-monitor
        irc_realname: openSUSE Alertmanager IRC Relay
        # secrets are in pillar/secrets/role/monitoring/alertmanager.sls 
        irc_channels:
          # these are channels the bot will pre-join to
          # note that the bot can also dynamically join channels alerts are sent to without them being listed here
          - name: '#opensuse-admin-alerts'

prometheus:
  wanted:
    component:
      - alertmanager
  pkg:
    component:
      alertmanager:
        config:
          route:
            group_by:
              - alertname
            receiver: irc
          receivers:
            - name: irc
              webhook_configs:
                - url: http://ipv6-localhost:8008/opensuse-admin-alerts
                  send_resolved: true

zypper:
  packages:
    alertmanager-irc-relay: {}

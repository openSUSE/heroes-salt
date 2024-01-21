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
            receiver: opensuse-beta
          receivers:
            - name: opensuse-beta
              webhook_configs:
                - url: http://ipv6-localhost:8008/opensuse-admin-alerts
                  send_resolved: true
              email_configs:
                - to: georg+opensuse@syscid.com
                  from: alertmanager@monitor.infra.opensuse.org
                  require_tls: false
                  smarthost: relay.infra.opensuse.org:25
                  send_resolved: yes
        environ:
          environ_arg_name: ARGS  # SUSE package specific
          args:
            cluster.advertise-address: '{{ grains['fqdn_ip6'][0] | ipwrap }}:9904'
            cluster.listen-address: ''  # TODO: configure HA

zypper:
  packages:
    alertmanager-irc-relay: {}

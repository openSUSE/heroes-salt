include:
  - role.common.monitoring
{%- if salt['grains.get']('include_secrets', True) %}
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
          inhibit_rules:
            - source_matchers:
                - alertname="Node down"
              target_matchers:
                - alertname="Node away"
              equal:
                - instance
            - source_matchers:
                - alertname="Low disk space"
              target_matchers:
                - alertname="Low disk space predicted"
              equal:
                - instance
            - source_matchers:
                - alertname="Member aliases update failed due to too many removals"
              target_matchers:
                - alertname="Member aliases update failed"
              equal:
                - instance
          time_intervals:
            - name: update_window
              time_intervals:
                - times:
                  - start_time: 00:00
                    end_time: 05:00
          receivers:
            - name: opensuse  # dashboard only
            - name: opensuse-irc
              webhook_configs:
                - url: http://ipv6-localhost:8008/opensuse-admin-alerts
                  send_resolved: true
            - name: opensuse-mail
              email_configs:
                - to: admin-auto@opensuse.org
                  from: alertmanager@monitor.infra.opensuse.org
                  require_tls: false
                  smarthost: relay.infra.opensuse.org:25
                  send_resolved: true
          route:
            group_by:
              - alertname
            receiver: opensuse-irc  # default if no routes match
            routes:
              - matchers:
                  - severity=~"none|info"
                receiver: opensuse
                continue: false
              - matchers:
                  - monitor=opensuse
                  - severity!=none
                receiver: opensuse-irc
                continue: true
              - matchers:
                  - monitor=opensuse
                  - severity=critical
                receiver: opensuse-mail
                mute_time_intervals:
                  - update_window
        environ:
          environ_arg_name: ARGS  # SUSE package specific
          args:
            cluster.advertise-address: '{{ grains['fqdn_ip6'][0] | ipwrap }}:9904'
            cluster.listen-address: ''  # TODO: configure HA
            web.external-url: http://monitor.infra.opensuse.org:9093

zypper:
  packages:
    alertmanager-irc-relay: {}

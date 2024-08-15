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
      promact:
        config:
          loglevel: debug
          alerts:
            MySQLTooManyConnections:
              status: firing
              shell: /usr/local/libexec/promact/check-mysql.sh
              map:
                instance: INSTANCE

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
                - alertname=~"Low disk space \(?:big|small\)"
              target_matchers:
                - alertname="Low disk space predicted"
              equal:
                - instance
            - source_matchers:
                - alertname="Pending updates"
              target_matchers:
                - alertname=~"Pending updates \((?:not )?reboot safe\)"
              equal:
                - instance
            - source_matchers:
                - alertname="Needs rebooting"
              target_matchers:
                - alertname=~"Needs rebooting \((?:not )?reboot safe\)"
              equal:
                - instance
            - source_matchers:
                - alertname="Member aliases update failed due to too many removals"
              target_matchers:
                - alertname="Member aliases update failed"
              equal:
                - instance
            - source_matchers:
                - alertname="HAProxyBackendServerDown"
                - proxy="galera"
              target_matchers:
                - alertname="HAProxyBackendServerDown"
                - proxy="galera-slave"
              equal:
                - instance
                - server
            - source_matchers:
                - alertname="SMART Very High Device Temperature"
              target_matchers:
                - alertname="SMART High Device Temperature"
              equal:
                - instance
                - device
          templates:
            - /etc/prometheus/templates/*.template
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
                  html: ''
                  text: {% raw -%} '{{ template "email.ioo.txt" . }}' {%- endraw %}
            - name: opensuse-action
              webhook_configs:
                - url: http://ipv6-localhost:8010/call
                  send_resolved: false
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
                continue: true
              - matchers:
                  - monitor=opensuse
                receiver: opensuse-action
        environ:
          environ_arg_name: ARGS  # SUSE package specific
          args:
            cluster.advertise-address: '{{ grains['fqdn_ip6'][0] | ipwrap }}:9904'
            cluster.listen-address: "''"  # TODO: configure HA
            web.external-url: http://monitor.infra.opensuse.org:9093

zypper:
  packages:
    alertmanager-irc-relay: {}
    promact: {}

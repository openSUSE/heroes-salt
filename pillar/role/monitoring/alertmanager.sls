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
                - url: http://ipv6-localhost/opensuse-admin-alerts
                  send_resolved: true

cluster: ipx-proxy
grains:
  site: nue-ipx
  hostusage:
    - Proxy
  reboot_safe: yes

  aliases: []
  description: Runs HAProxy, questionable condition
  documentation: []
  responsible: []
  partners: []
  weburls: []
roles:
  - proxy
firewalld:
  enabled: true
  zones:
    internal:
      interfaces:
        - private
      ports:
        - comment: HAProxy Prometheus Exporter
          port: 8404
          protocol: tcp
      services:
        - dns
        - http
        - https
    public:
      interfaces:
        - external
      services:
        - http
        - https

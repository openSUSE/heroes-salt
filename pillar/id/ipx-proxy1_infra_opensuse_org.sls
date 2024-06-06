grains:
  country: de
  hostusage:
    - Proxy
  reboot_safe: yes

  aliases: []
  description: Runs HAProxy, questionable condition
  documentation: []
  responsible: []
  partners: []
  weburls: []
roles: []
firewalld:
  enabled: true
  zones:
    internal:
      interfaces:
        - private
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

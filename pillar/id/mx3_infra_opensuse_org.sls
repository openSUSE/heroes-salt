grains:
  site: nue-ipx
  hostusage: []
  reboot_safe: yes
  aliases:
    - ipx-mx1.infra.opensuse.org
  description: unused mail server
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
    public:
      interfaces:
        - external

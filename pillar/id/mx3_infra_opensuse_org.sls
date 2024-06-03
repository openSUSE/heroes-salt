grains:
  country: de
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
      services:
        - nrpe
    public:
      interfaces:
        - external

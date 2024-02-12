grains:
  country: us
  hostusage:
    - DNS
  reboot_safe: yes

  aliases:
    - ns3.infra.opensuse.org
  description: Public DNS server for the opensuse.org domain (not reverse)
  documentation:
    - https://progress.opensuse.org/projects/opensuse-admin-wiki/wiki/DNS
  responsible:
    - lrupp
  partners:
    - prg-ns1.infra.opensuse.org
    - prg-ns2.infra.opensuse.org
    - qsc-ns3.infra.opensuse-org
  weburls: []
roles:
  - nameserver.legacy_secondary
firewalld:
  enabled: true
  zones:
    internal:
      interfaces:
        - private
      services:
        - dns
        - nrpe
    public:
      interfaces:
        - external
      services:
        - dns

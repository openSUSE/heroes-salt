grains:
  site: slc1
  hostusage:
    - DNS
  reboot_safe: yes
  aliases:
    - slc-ns2.opensuse.org
    - ns3.opensuse.org
  description: Public authoritative and internal recursive name server
  documentation: []
  responsible: []
  partners:
    - prg-ns1.infra.opensuse.org
    - prg-ns2.infra.opensuse.org
    - qsc-ns3.infra.opensuse.org
    - slc-ns1.infra.opensuse.org
  weburls: []
roles:
  - nameserver.recursor
  - nameserver.secondary
profile:
  dns:
    powerdns:
      recursor:
        addr_self: 2a07:de40:617e:1904::7
        addr_partner: 2a07:de40:617e:1904::6

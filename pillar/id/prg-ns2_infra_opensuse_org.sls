grains:
  site: prg2
  hostusage:
    - DNS
  reboot_safe: yes
  aliases:
    - ns4.opensuse.org
  description: Public, authoritative, name server
  documentation: []
  responsible: []
  partners:
    - prg-ns1.infra.opensuse.org
    - qsc-ns3.infra.opensuse.org
  weburls: []
roles:
  - nameserver.recursor
  - nameserver.secondary
profile:
  dns:
    powerdns:
      recursor:
        addr_self: 2a07:de40:b27e:1204::22
        addr_partner: 2a07:de40:b27e:1204::21

include:
  - cluster.prg-ns

grains:
  country: cz
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
    - provo-ns.infra.opensuse.org
    - qsc-ns3.infra.opensuse.org
  weburls: []
roles:
  - nameserver.recursor
  - nameserver.secondary
profile:
  dns:
    powerdns:
      recursor:
        config:
          local_address:
            - '[2a07:de40:b27e:1204::22]:1053'
          webserver_address: 2a07:de40:b27e:1204::22

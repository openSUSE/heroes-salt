include:
  - cluster.prg-ns

grains:
  city: prague
  country: cz
  hostusage:
    - DNS
  reboot_safe: yes
  virt_cluster: falkor
  aliases:
    - ns2.opensuse.org
  description: Public, authoritative, name server
  documentation: []
  responsible: []
  partners:
    - prg-ns2.infra.opensuse.org
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
            - '[2a07:de40:b27e:1204::21]:1053'
          webserver_address: 2a07:de40:b27e:1204::21

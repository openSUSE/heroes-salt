grains:
  country: de
  hostusage:
    - DNS
  reboot_safe: yes

  aliases: 
    - ns1.infra.opensuse.org
  description: Public, authoritative, name server
  documentation: 
    - https://progress.opensuse.org/projects/opensuse-admin-wiki/wiki/DNS
  responsible:
    - lrupp
  partners:
    - prg-ns1.infra.opensuse.org
    - prg-ns2.infra.opensuse.org
    - provo-ns.infra.opensuse.org
  weburls: []
roles:
  - nameserver.legacy_secondary

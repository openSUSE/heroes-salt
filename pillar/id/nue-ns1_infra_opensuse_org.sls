grains:
  city: nuremberg
  country: de
  hostusage:
    - DNS
  roles: 
    - dns
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: atreju

  aliases:
    - ns1.infra.opensuse.org
    - ns1.opensuse.org
  description: Public DNS server for the opensuse.org domain (not reverse)
  documentation:
    - https://progress.opensuse.org/projects/opensuse-admin-wiki/wiki/DNS
  responsible:
    - lrupp
  partners:
    - nue-ns2.infra.opensuse.org
    - qsc-ns3.infra.opensuse-org
    - provo-ns.infra.opensuse.org
  weburls: []

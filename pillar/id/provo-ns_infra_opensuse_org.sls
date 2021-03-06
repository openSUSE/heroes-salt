grains:
  city: provo
  country: us
  hostusage:
    - DNS
  roles: 
    - dns
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: bryce

  aliases:
    - ns4.infra.opensuse.org
  description: Public DNS server for the opensuse.org domain (not reverse)
  documentation:
    - https://progress.opensuse.org/projects/opensuse-admin-wiki/wiki/DNS
  responsible:
    - lrupp
  partners:
    - nue-ns1.infra.opensuse.org
    - nue-ns2.infra.opensuse.org
    - qsc-ns3.infra.opensuse-org
  weburls: []

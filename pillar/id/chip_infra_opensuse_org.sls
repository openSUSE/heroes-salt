grains:
  city: nuremberg
  country: de
  hostusage:
    - pDNS master
  roles:
    - ns
    - ns_slave
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: atreju

  aliases:
    - ext-ns.infra.opensuse.org
  description: Hidden DNS for zone transfers from FreeIPA to public DNS servers
  documentation: []
  responsible: []
  partners: []
  weburls: []

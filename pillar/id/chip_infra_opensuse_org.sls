grains:
  city: nuremberg
  country: de
  hostusage:
    - pDNS master
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: atreju

  aliases:
    - ext-ns.infra.opensuse.org
  description: Hidden DNS master
  documentation: []
  responsible: []
  partners: []
  weburls: []
roles:
  - nameserver.primary

grains:
  site: prg2
  hostusage:
    - pDNS master
  reboot_safe: yes

  aliases:
    - ext-ns.infra.opensuse.org
  description: Hidden DNS master
  documentation: []
  responsible: []
  partners: []
  weburls: []
roles:
  - nameserver.primary

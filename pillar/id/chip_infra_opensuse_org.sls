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
motd:
  - '====='
  - 'DNS zones are managed through Git now.'
  - 'Submit your changes to https://git.infra.opensuse.org/infra/dns.'
  - 'Manual changes will be reverted. No mercy.'
  - '======'
roles:
  - nameserver.primary

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
  - 'Dear fellow administrator, DNS zones are partially managed by OpenTofu now.'
  - 'Before using pdnsutil, please check https://gitlab.infra.opensuse.org/infra/tofu.'
  - 'If the zone you intended to modify is listed in the repository, stop here and submit a patch there.'
  - '======'
roles:
  - nameserver.primary

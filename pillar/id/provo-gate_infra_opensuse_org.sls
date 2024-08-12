include:
  - secrets.include_id

grains:
  site: prv1
  hostusage:
    - gate.o.o
  reboot_safe: yes

  aliases:
    - gate.infra.opensuse.org
    - gate2.opensuse.org
  description: OpenVPN gateway for infra.opensuse.org hosts in Provo (to reach NUE machines)
  documentation:
  responsible:
    - lrupp
  partners: []
  weburls: []
roles:
  - vpn.site_to_site

sysctl:
  params:
    net.ipv4.ip_forward: 1
    net.ipv6.conf.all.forwarding: 1

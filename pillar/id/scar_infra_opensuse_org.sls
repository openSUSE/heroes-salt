grains:
  city: nuremberg
  country: de
  hostusage:
    - gate.o.o
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: atreju

  aliases:
    - gate.infra.opensuse.org
    - gate.opensuse.org
    - scar.opensuse.org
  description: OpenVPN gateway and central outgoing gateway for infra.opensuse.org hosts
  documentation:
    - https://progress.opensuse.org/projects/opensuse-admin-wiki/wiki/VPN
  responsible:
    - mcaj
    - rklein
  partners: []
  weburls: []
roles:
  - openvpn

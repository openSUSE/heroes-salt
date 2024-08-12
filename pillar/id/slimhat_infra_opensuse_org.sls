grains:
  site: nue-ipx
  hostusage:
    - Hypervisor
    - IPMI access
  reboot_safe: yes

  aliases: []
  description: Hypervisor and IPMI bastion for stonehat.infra.opensuse.org
  documentation: []
  responsible:
    - bmwiedemann
    - gpfuetzenreuter
  partners: []
  weburls: []
roles:
  - hypervisor.standalone

# Firewall configuration
firewalld:
  enabled: true
  LogDenied: 'off'
  default_zone: public

  services:
    wireguard:
      short: VPN interconnect
      description: >-
        These ports are required for interconnect tunnels
      ports:
        udp:
          - 52456
          - 51123

  zones:
    internal:
      short: heroes-internal
      description: >-
        Internal VPN network.
      interfaces:
        - pciright
        - tun0
        - wg0
        - wg_siterouting
      services:
        - monitoring
        - munin-node
        - smartctl_exporter
    heroes-external:
      short: heroes-external
      description: >-
        Special ZONE with openSUSE VPN external IP addresses, so we can
        guarantee that we have public access to SSH in case VPN goes down, but
        without exposing SSH to the internet.
      sources:
        # SUSE's public networks (Nuremberg+Prague)
        - 195.135.220.0/22
        # SUSE's public network (Prague)
        - 213.151.88.128/25
        # provo-mirror.o.o etc
        - 91.193.113.0/24
        # QSC public networks (i.e. widehat)
        - 62.146.92.200/29
        - 62.146.92.208/29
        # Backdoor of @bmwiedemann for the time being
        - 188.40.142.18
      services:
        - ssh
    public:
      short: Public
      interfaces:
        - pcileft
        - onboardleft
        - br0
        - br1
      services:
        - wireguard
    # NOT USED ZONES -- let it be to keep them clear and not attached to any
    # interface or sources and without any service declared.
    heroes-internal:
      short: old heroes-internal
      description: migrated to internal
    work:
      short: Work
    trusted:
      short: Trusted
smartmontools:
  smartd:
    config:
      - /dev/sda
      - /dev/sdb
prometheus:
  pkg:
    component:
      smartctl_exporter:
        environ:
          args:
            smartctl.device:
              - /dev/sda
              - /dev/sdb

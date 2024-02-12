grains:
  country: de
  hostusage:
    - IPMI access
  reboot_safe: yes

  aliases: []
  description: IPMI backdoor for widehat.infra.opensuse.org (Remote access) and hypervisor for VMs
  documentation: []
  responsible:
    - bmwiedemann
    - gpfuetzenreuter
    - mcaj
    - lrupp
  partners: []
  weburls: []

# Firewall configuration
firewalld:
  enabled: true
  LogDenied: 'off'
  default_zone: public

  services:
    monitoring:
      short: monitoring
      description: >-
        This port is required for monitoring based on NRPE.
      ports:
        tcp:
          - 5665
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
profile:
  monitoring:
    nrpe:
      server_address: 2a07:de40:b27e:5001::193
roles: []

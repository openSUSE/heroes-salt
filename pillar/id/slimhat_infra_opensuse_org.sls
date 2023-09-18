grains:
  city: QSC-nuremberg
  country: de-qsc
  hostusage:
    - IPMI access
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: slimhat-bare

  aliases: []
  description: IPMI backdoor for widehat.infra.opensuse.org (Remote access) and hypervisor for VMs (use slimhat as virt_cluster entry)
  documentation: []
  responsible:
    - kbabioch
    - mcaj
    - rklein
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
        These ports are required for monitoring based on check_mk and NRPE.
      ports:
        tcp:
          - 5665
          - 6556

  zones:
    heroes-internal:
      short: heroes-internal
      description: >-
        Internal VPN network.
      interfaces:
        - tun0
      services:
        - ssh
        - monitoring
    heroes-external:
      short: heroes-external
      description: >-
        Special ZONE with openSUSE VPN external IP addresses, so we can
        guarantee that we have public access to SSH in case VPN goes down, but
        without exposing SSH to the internet.
      sources:
        # SUSE's public networks (Nuremberg)
        - 195.135.220.0/24
        - 195.135.221.0/24
        # SUSE's public network (Prague)
        - 213.151.88.128/25
        # QSC public networks (i.e. widehat)
        - 62.146.92.200/29
        - 62.146.92.208/29
        # Backdoor of @kbabioch for the time being
        - 24.134.156.21
        # Backdoor of @rklein for the time being
        - 72.14.176.247
      services:
        - ssh
    # NOT USED ZONES -- let it be to keep them clear and not attached to any
    # interface or sources and without any service declared.
    public:
      short: Public
    internal:
      short: Internal
    work:
      short: Work
    trusted:
      short: Trusted
roles:
  - firewall

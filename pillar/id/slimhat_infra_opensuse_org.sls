grains:
  city: QSC-nuremberg
  country: de-qsc
  roles:
    - firewall
  hostusage:
    - IPMI access
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: bare-metal

  aliases: []
  description: IPMI backdoor for widehat.infra.opensuse.org (Remote access)
  documentation: []
  responsible:
    - kbabioch
    - mcaj
    - rklein
  partners: []
  weburls: []

# Firewall configuration
firewalld:
  enabled: true
  LogDenied: 'off'
  default_zone: public

  zones:
    heroes-internal:
      short: heroes-internal
      description: >-
        Internal VPN network.
      interfaces:
        - tun0
      services:
        - ssh
    heroes-external:
      short: heroes-external
      description: >-
        Special ZONE with openSUSE VPN external IP addresses, so we can
        guarantee that we have public access to SSH in case VPN goes down, but
        without exposing SSH to the internet.
      sources:
        - 195.135.221.151
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
      services:
        - ssh
    internal:
      short: Internal
    work:
      short: Work
    trusted:
      short: Trusted

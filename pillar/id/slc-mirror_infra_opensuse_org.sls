grains:
  site: slc1
  hostusage:
    - mirror
  reboot_safe: yes
  description: Public HTTP/rsync mirror for openSUSE packages
  documentation: []
  responsible: []
  partners: []
  weburls:
    - http://provo-mirror.opensuse.org/
roles: []

firewalld:
  enabled: true
  services:
    rsync-mirror:
      description: openSUSE pull/push rsync mirror
      ports:
        tcp:
          - 873
          - 874
  zones:
    backchannel:
      interfaces:
        - os-mirror-bc
      services:
        - nfs
    internal:
      interfaces:
        - os-mirror
      services:
        - http
        - rsync-mirror

network:
  interfaces:
    os-mirror-bc:
      mtu: 9216

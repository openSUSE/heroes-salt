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
roles:
  - mirror.external

network:
  interfaces:
    os-mirror-bc:
      mtu: 9000

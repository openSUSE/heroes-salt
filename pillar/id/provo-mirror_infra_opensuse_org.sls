grains:
  city: provo
  country: us
  hostusage:
    - mirror
  reboot_safe: yes

  aliases:
    - twsnapshot.opensuse.org
  description: Externally hosted mirror distribution source (HTTP/rsync) for openSUSE packages
  documentation: []
  responsible:
    - lrupp
  partners: 
    - pontifex2.infra.opensuse.org
    - widehat.infra.opensuse.org
  weburls:
    - http://provo-mirror.opensuse.org/
    - http://twsnapshot.opensuse.org/
roles:
  - debuginfod

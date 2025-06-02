grains:
  site: prg2
  hostusage:
    - Kanidm (External)
    - Development
  reboot_safe: yes
  aliases: []
  description: External identity provider and authentication service (development/test environment)
  documentation:
    - https://kanidm.com/
    - https://kanidm.github.io/kanidm/stable/
  responsible:
    - firstyear
  partners:
    - kani-ext-dev1.infra.opensuse.org
  weburls: []
roles:
  - kanidm-server.external

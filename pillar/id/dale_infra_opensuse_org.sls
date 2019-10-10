grains:
  city: nuremberg
  country: de
  hostusage:
    - events.o.o
  roles:
    - web_osem
  reboot_safe: yes
  # Henne created zypper locks for ruby2.5 because a version change breaks osem (needs a Gemfile update when the version changes)
  salt_cluster: opensuse
  virt_cluster: atreju

  aliases: []
  description: Conference website and management
  documention: []
  responsible: []
  partners: []
  weburls:
    - https://events.opensuse.org

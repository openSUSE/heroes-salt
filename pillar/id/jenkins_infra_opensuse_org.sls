grains:
  city: nuremberg
  country: de
  hostusage:
    - jenkins controller
    - jenkins agent
  reboot_safe: yes
  virt_cluster: atreju

  aliases: []
  description: Another Jenkins instance, but open to the openSUSE community.
  documentation:
    - https://jenkins.io/
  responsible: []
  partners: []
  weburls: []
roles:
  - web_jenkins
  - worker_jenkins

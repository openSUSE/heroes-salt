grains:
  city: nuremberg
  country: de
  hostusage:
    - jenkins controller
    - jenkins agent
  roles:
    - web_jenkins
    - worker_jenkins
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: atreju

  aliases: []
  description: Another Jenkins instance, but open to the openSUSE community.
  documentation:
    - https://jenkins.io/
  responsible: []
  partners: []
  weburls: []

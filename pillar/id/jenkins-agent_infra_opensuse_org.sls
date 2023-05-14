grains:
  city: nuremberg
  country: de
  hostusage:
    - jenkins agent
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: atreju

  aliases: []
  description: Testing machhine to serve as a Jenkins Agent.
  documentation:
    - https://jenkins.io/
  responsible:
    - luc14n0
  partners: []
  weburls: []
roles:
  - worker_jenkins

grains:
  city: nuremberg
  country: de
  hostusage:
    - Jenkins Containers
  reboot_safe: yes
  salt_cluster: opensuse
  virt_cluster: atreju

  aliases: []
  description: Docker for Jenkins
  documentation:
    - https://jenkins.io/
    - https://docs.docker.com/
  responsible:
    - crameleon
  partners: []
  weburls: []
roles:
  - docker
profile:
  docker:
    data_root: /data/docker

grains:
  city: nuremberg
  country: de
  hostusage:
    - Jenkins Containers
  roles:
    - docker
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

profile:
  docker:
    data_root: /data/docker

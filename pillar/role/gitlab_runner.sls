include:
  - .docker

profile:
  docker:
    daemon:
      ipv6: true
      fixed-cidr-v6: 2a07:de40:b27e:400{{ grains['host'][-1] }}::/64

sysctl:
  params:
    vm.swappiness: 5

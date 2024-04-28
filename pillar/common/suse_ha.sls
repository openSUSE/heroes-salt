mine_functions:
  network.get_hostname: []
suse_ha:
  resources_dir: /kvm/cluster-resources
  cluster:
    crypto_cipher: aes256
    crypto_hash: sha512
    ip_version: ipv6
  fencing:
    stonith_enable: True
  management:
    allow-migrate: True
    migration-limit: 15
    no-quorum-policy: stop
firewalld:
  services:
    corosync:
      ports:
        udp:
          - 5404
          - 5405
          - 5406
  zones:
    cluster:
      description: Cluster network (openSUSE-falkor-cluster-ur)
      services:
        - corosync
        - ssh
        - libvirt
        - libvirtd-relocation-server
sysctl:
  params:
    kernel.hostname: {{ grains['id'] }}

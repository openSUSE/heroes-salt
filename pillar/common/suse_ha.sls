mine_functions:
  network.get_hostname: []
suse_ha:
  cluster:
    crypto_cipher: aes256
    crypto_hash: sha512
    ip_version: ipv6
  fencing:
    stonith_enable: True
  management:
    no_quorum_policy: stop
    allow_migrate: True
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

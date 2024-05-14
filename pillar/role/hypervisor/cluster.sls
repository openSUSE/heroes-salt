include:
  - .common
  - common.suse_ha

firewalld:
  enabled: true
  zones:
    main:
      description: Main network (openSUSE-bare)
      services:
        - node_exporter
        - ssh
    nfs:
      description: NFS network (openSUSE-falkor-nfs-ur)

hostsfile:
  alias: clusterip
  domain: infra.opensuse.org
  minions: falkor*.infra.opensuse.org

infrastructure:
  image_type: raw

libvirt:
  libvirtd:
    auth_tcp: none
    max_client_requests: 256
    max_workers: 128
  virtlockd:
    max_client_requests: 256
  virtlogd:
    max_client_requests: 256

multipath:
  blacklist:
    protocol: ^scsi:ata$

os-update:
  ignore_services_from_restart:
    - corosync
    - pacemaker
    - sbd

prometheus:
  wanted:
    component:
      - hacluster_exporter

sudoers:
  groups:
    hypervisor.cluster-admins:
      # commands used by lun_provision
      - >-
        {{ grains['host'] }}=(root) NOPASSWD:
        /sbin/multipath -f [[\:alnum\:]]*,
        /sbin/multipath -l [a-z0-9/]*,
        /sbin/multipath -ll [[\:alnum\:]]*,
        /sbin/multipathd -k\ disablequeueing\ multipath\ [[\:alnum\:]]*,
        /sbin/multipathd -k\ resize\ map\ [[\:alnum\:]]*,
        /usr/bin/rescan-scsi-bus.sh -s,
        /usr/bin/rescan-scsi-bus.sh --luns=[[\:digit\:]]*

sysctl:
  params:
    net.ipv6.route.max_size: 8192

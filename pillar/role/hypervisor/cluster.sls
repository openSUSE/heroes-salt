include:
  - .common
  - common.suse_ha

firewalld:
  zones:
    main:
      description: Main network (openSUSE-bare)
      services:
        - ssh
      ports:
        - comment: node_exporter
          port: 9100
          protocol: tcp
    nfs:
      description: NFS network (openSUSE-falkor-nfs-ur)

hostsfile:
  alias: clusterip
  domain: infra.opensuse.org
  minions: falkor*.infra.opensuse.org

os-update:
  ignore_services_from_restart:
    - corosync
    - pacemaker
    - sbd

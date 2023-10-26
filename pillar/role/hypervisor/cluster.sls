include:
  - .common
  - common.suse_ha

firewalld:
  zones:
    main:
      description: Main network (openSUSE-bare)
      services:
        - ssh
    nfs:
      description: NFS network (openSUSE-falkor-nfs-ur)

hostsfile:
  alias: clusterip
  domain: infra.opensuse.org
  minions: falkor*.infra.opensuse.org

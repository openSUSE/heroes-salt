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

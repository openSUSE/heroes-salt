include:
  - common.suse_ha

firewalld:
  zones:
    infra-main:
      description: Main network (openSUSE-bare)
      services:
        - ssh
    infra-nfs:
      description: NFS network (openSUSE-falkor-nfs-ur)

firewalld:
  zones:
    cluster:
      interfaces:
        - os-f-cluster
    main:
      interfaces:
        - os-bare
    nfs:
      interfaces:
        - os-f-nfs

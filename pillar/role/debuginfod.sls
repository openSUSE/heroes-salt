# no service configuration yet :-(

firewalld:
  enabled: true
  services:
    debuginfod:
      description: elfutils debuginfod
      ports:
        tcp:
          - 8002
  zones:
    backchannel:
      interfaces:
        - os-mirror-bc
    internal:
      interfaces:
        - os-dbginfod
      services:
        - debuginfod

nfs:
  mount:
    mirror:
      # slc-mirror.i.o.o via os-mirror-bc
      location: '[fd4d:665a:d688:1708::a]:/'
      mountpoint: /mirror
      opts:
        - _netdev
        - async
        - auto
        - nconnect=16
        - noexec
        - nofail

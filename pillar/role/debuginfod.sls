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
    internal:
      interfaces:
        - os-dbginfod
      services:
        - debuginfod

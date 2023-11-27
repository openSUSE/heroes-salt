mine_functions:
  clusterip:
    mine_function: network.ip_addrs6
    interface: eth0

suse_ha:
  cluster:
    name: runner
    nodeid: 1
  fencing:
    stonith_enable: false
    sbd:
      devices:
        - /dev/null
      instances:
        test1:
          pcmk_host_check: static-list
  multicast:
    address: 'ff00:1::'
    bind_address: fd4b:5292::1
  sysconfig:
    sbd:
      SBD_WATCHDOG_DEV: /dev/watchdog

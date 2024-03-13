nftables: true

zypper:
  packages:
    conntrackd: {}
    nftables: {}
    vnstat: {}
    wireguard-tools: {}

sysctl:
  params:
    net.ipv4.ip_forward: 1
    net.ipv6.conf.all.forwarding: 1

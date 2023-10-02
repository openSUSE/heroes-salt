zypper:
  packages:
    conntrackd: {}
    keepalived: {}
    nftables: {}
    nftables-service: {}
    vnstat: {}
    wireguard-tools: {}

sysctl:
  params:
    net.ipv4.ip_forward: 1
    net.ipv6.conf.all.forwarding: 1

# nftables formula and keepalived pillars under construction ...

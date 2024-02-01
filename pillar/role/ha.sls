include:
  - common.keepalived

sysctl:
  params:
    net.ipv4.ip_nonlocal_bind: 1
    net.ipv6.ip_nonlocal_bind: 1
    net.netfilter.nf_conntrack_tcp_timeout_established: 12000
    net.netfilter.nf_conntrack_tcp_timeout_time_wait: 100

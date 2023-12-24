{% set host = salt['grains.get']('host') %}

keepalived:
  global_defs:
    notification_email_from: {{ host }}+keepalived@infra.opensuse.org
    notification_email:
      - admin-auto@opensuse.org
    smtp_connect_timeout: 30
    smtp_server: relay.infra.opensuse.org

sysctl:
  params:
    net.ipv4.ip_nonlocal_bind: 1
    net.ipv6.ip_nonlocal_bind: 1
    net.netfilter.nf_conntrack_tcp_timeout_established: 12000
    net.netfilter.nf_conntrack_tcp_timeout_time_wait: 100

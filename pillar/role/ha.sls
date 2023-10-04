{% set host = salt['grains.get']('host') %}

keepalived:
  global_defs:
    notification_email_from: keepalived+{{ host }}@opensuse.org
    notification_email:
      - admin-auto@opensuse.org
    smtp_connect_timeout: 30
    # TODO: smtp_server: relay.infra.opensuse.org as soon as https://bugzilla.opensuse.org/show_bug.cgi?id=1076896 is fixed
    smtp_server: 192.168.47.4

sysctl:
  params:
    net.ipv4.ip_nonlocal_bind: 1
    net.ipv6.ip_nonlocal_bind: 1
    net.netfilter.nf_conntrack_tcp_timeout_established: 12000
    net.netfilter.nf_conntrack_tcp_timeout_time_wait: 100

sysctl:
  params:
    {#-
      Maximum number  of  packets,  queued  on  the  INPUT  side, when the interface
      receives packets faster than kernel can process them.
      FIXME: elaborate which systems benefir from this and how
    #}
    net.core.netdev_max_backlog: 50000

    {#-
      Enable Explicit Congestion Notification (ECN) when requested by incoming connections and
      also request ECN on outgoing connection attempts.
    #}
    net.ipv4.tcp_ecn: 1

    {%- if grains.get('country') != 'cz' %}
    {#-
      Disable router advertisements (which are currently only being used in our network in Prague).
    #}
    net.ipv6.conf.all.accept_ra: 0
    {%- endif %}

    {#-
      Log packets with impossible addresses to kernel log.
    #}
    net.ipv4.conf.all.log_martians: 1

    {#-
      Increase the maximum amount of option memory buffers.
      FIXME: Elaborate on how this is useful. Only reasonably useful reference found at the time of writing:
      https://indico.cern.ch/event/212228/contributions/1507212/attachments/333941/466017/10GE_network_tests_with_UDP.pdf
    #}
    net.core.optmem_max: 65536

    {#-
      Maximum number of TCP keep-alive probes to send before killing the connection if no response is obtained.
    #}
    net.ipv4.tcp_keepalive_probes: 5
    {#-
      Multiplied by tcp_keepalive_probes it is the time to kill not responding connections.
    #}
    net.ipv4.tcp_keepalive_intvl: 15

{#-
  the following are sysctl parameters which might be useful in the future:

# Set ARP cache entry timeout
net.ipv4.neigh.default.gc_stale_time = 3600
net.ipv6.neigh.default.gc_stale_time = 3600
# Setup DNS threshold for arp
net.ipv4.neigh.default.gc_thresh3 = 4096
net.ipv4.neigh.default.gc_thresh2 = 2048
net.ipv4.neigh.default.gc_thresh1 = 1024
net.ipv6.neigh.default.gc_thresh3 = 4096
net.ipv6.neigh.default.gc_thresh2 = 2048
net.ipv6.neigh.default.gc_thresh1 = 1024
# Force gc to clean-up quickly
net.ipv4.neigh.default.gc_interval = 3600
net.ipv6.neigh.default.gc_interval = 3600

This is interesting on servers where kernel messages such as "arp_cache: neighbor table overflow!" are observed. On internal machines this should never happen. If it does happen on internet connected machines, we can tune these on a role or id basis.

# Increase the tcp-time-wait buckets pool size to prevent simple DOS attacks
net.ipv4.tcp_max_tw_buckets = 1440000
# Limit number of orphans, each orphan can eat up to 16M (max wmem) of unswappable memory
net.ipv4.tcp_max_orphans = 16384
# Increase the maximum memory used to reassemble IP fragments
net.ipv4.ipfrag_low_thresh = 446464
# Increase the tcp-time-wait buckets pool size to prevent simple DOS attacks
net.ipv4.tcp_max_tw_buckets = 1440000

This is interesting on machines suffering from bad actors on the internet?
FIXME: Elaborate how to determine when this is useful and how to tune the values.
If this is set, it should be considered on a role or id level, as it does not seem situations in scope should occur on internal systems.
NOTE: Some of these values would need to be tuned according to the available system memory!

net.ipv4.tcp_tw_reuse = 1
Can be used in case of problems with "TIME-WAIT" connections, according to https://vincent.bernat.ch/en/blog/2014-tcp-time-wait-state-linux.

# Increase TCP queue length
net.ipv4.neigh.default.proxy_qlen = 96
net.ipv4.neigh.default.unres_qlen_bytes = 6
Can be tuned if proxy-ARP is used.
net.core.rmem_default = 16777216

# TCP Autotuning setting: how the TCP stack should behave when it comes to memory usage
net.ipv4.tcp_mem=8388608 8388608 8388608
# TCP Autotuning setting:  receive buffer
#net.ipv4.tcp_rmem=4096 87380 8388608
net.ipv4.tcp_rmem=1048576 4194304 16777216
# TCP Autotuning setting: how much TCP sendbuffer memory space each TCP socket has to use
#net.ipv4.tcp_wmem=4096 65536 8388608
net.ipv4.tcp_wmem=1048576 4194304 16777216
#
net.core.wmem_default = 16777216
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216

https://www.tecchannel.de/a/tcp-ip-tuning-fuer-linux,429773,6 suggests this is for low memory situations.
FIXME: Explain how to determine whether this is useful.

# Decrease the time default value for tcp_fin_timeout connection
net.ipv4.tcp_fin_timeout = 15
# Decrease the time default value for connections to keep alive
net.ipv4.tcp_keepalive_time = 300

"This specifies how many seconds to wait for a final FIN packet before the socket is forcibly closed. This is strictly a violation of the TCP specification, but required to prevent denial-of-service attacks."

Might be useful on a role/id level for machines hosting services on the internet.
#}

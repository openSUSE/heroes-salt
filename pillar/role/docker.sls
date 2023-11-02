profile:
  docker:
    daemon:
      log-level: warn
      log-driver: json-file
      log-opts:
        max-size: 10m
        max-file: '5'

sysctl:
  params:
    {#-
      Pass bridged traffic to {arp,ip{,6}}tables chains.
      This is only useful on machines having legacy br_netfilter loaded and using legacy iptables,
      which means machines running Docker.
    #}
    net.bridge.bridge-nf-call-arptables: 0
    net.bridge.bridge-nf-call-ip6tables: 0
    net.bridge.bridge-nf-call-iptables: 0

{% for file in [ 'arp_settings.conf', 'basic_net_forwarding_and_syncookie_handling.conf', 'disable_ipv6_autoconf.conf', 'gc_interval.conf', 'ha_setup.conf', 'martians.conf',
    'pdns_recursor.conf', 'performance.conf', 'swapping.conf', 'syn_flooding_port_80.conf', 'tcp_timestamps.conf', 'tuning.conf', 'zzz_flush.conf', ] %}

/etc/sysctl.d/{{ file }}:
  file.managed:
    - source: salt://profile/sysctl/files/{{ file }}

{% endfor %}

/etc/sysctl.d/numa_balancing.conf:
  # was a workaround for bsc#1018330
  file.absent

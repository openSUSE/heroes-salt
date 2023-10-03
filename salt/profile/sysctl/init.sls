{%- set files = [ 'arp_settings.conf', 'basic_net_forwarding_and_syncookie_handling.conf', 'disable_ipv6_autoconf.conf', 'gc_interval.conf', 'ha_setup.conf', 'martians.conf', 'pdns_recursor.conf', 'performance.conf', 'swapping.conf', 'syn_flooding_port_80.conf', 'tcp_timestamps.conf', 'tuning.conf', 'zzz_flush.conf', 'numa_balancing.conf' ] %}

{%- for file in files %}
/etc/sysctl.d/{{ file }}:
  file.absent
{%- endfor %}

sysctl_update:
  cmd.run:
    - name: sysctl --system
    - onchanges:
      {%- for file in files %}
      - file: /etc/sysctl.d/{{ file }}
      {%- endfor %}

include:
  - sysctl.param

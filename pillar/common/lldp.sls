lldpd:
  sysconfig:
    lldpd_options: >-
      -C !*
      -I fib*,free*,mgmt*,ob*
      -m {{ grains['fqdn_ip6'][0] }}
      -M 1

{%- set addresses = grains['fqdn_ip6'] | ipaddr('private') %}

lldpd:
  sysconfig:
    lldpd_options: >-
      -C !*
      -I fib*,free*,mgmt*,ob*
      {{ '-m ' ~ addresses | first if addresses else '' }}
      -M 1

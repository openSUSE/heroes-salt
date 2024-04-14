nftables: true

bird:
  server:
    definitions:
      openSUSE_PRG2_Networks:
        - 2a07:de40:b27e:1200::/64
        - 2a07:de40:b27e:1203::/64
      openSUSE_PRG2_Networks_Legacy:
        - 172.16.129.0/24
        - 172.16.130.0/24
        - 172.16.131.0/24
        - 172.16.164.0/24
    logs:
      syslog: all
    watchdogs:
      warning: 5 s
      timeout: 30 s
    protocols:
      direct:
        ipv4: null
        ipv6: null
      {%- for i in [6, 4] %}
      kernel_{{ i }}:
        type: kernel
        ipv{{ i }}:
          filters:
            export:
              - openSUSE_direct
      {%- endfor %}

zypper:
  packages:
    conntrackd: {}
    nftables: {}
    vnstat: {}
    wireguard-tools: {}

sysctl:
  params:
    net.ipv4.ip_forward: 1
    net.ipv6.conf.all.forwarding: 1

ntp:
  ng:
    settings:
      ntp_conf:
        peer:
          - ntp1.infra.opensuse.org
          - ntp2.infra.opensuse.org
          - ntp3.infra.opensuse.org
        restrict:
          - ntp1.opensuse.org
          - ntp2.opensuse.org
          - 192.168.47.0 mask 255.255.255.0 kod nomodify notrap nopeer noquery
          - 192.168.254.0 mask 255.255.255.0 kod nomodify notrap nopeer noquery
        server:
          - ntp1.opensuse.org iburst prefer
          - ntp2.opensuse.org iburst

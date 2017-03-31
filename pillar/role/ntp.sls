ntp:
  ng:
    settings:
      restrict:
        - 149.44.161.0 mask 255.255.255.128
        - 192.168.0.0 mask 255.255.255.0
        - 192.168.2.0 mask 255.255.255.0
        - 192.168.254.0 mask 255.255.255.0
        - 195.135.220.0 mask 255.255.255.0
        - ntp1.ptb.de
        - ntp2.ptb.de
        - ntp0.rrze.uni-erlangen.de nomodify notrap nopeer noquery
        - ntp1.rrze.uni-erlangen.de nomodify notrap nopeer noquery
        - ntp2.rrze.uni-erlangen.de nomodify notrap nopeer noquery
      server:
        - ntp1.ptb.de iburst prefer
        - ntp2.ptb.de iburst prefer
        - ntp0.rrze.uni-erlangen.de
        - ntp1.rrze.uni-erlangen.de
        - ntp2.rrze.uni-erlangen.de

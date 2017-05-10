ntp:
  ng:
    settings:
      ntp_conf:
        filegen:
          - peerstats file peerstats type day enable
          - loopstats file loopstats type day enable
          - clockstats file clockstats type day enable
        fudge:
          - 127.127.1.0 stratum 10
        restrict:
          - 130.149.17.21 nomodify notrap nopeer noquery
          - 131.188.3.220 nomodify notrap nopeer noquery
          - 131.188.3.221 nomodify notrap nopeer noquery
          - 131.188.3.222 nomodify notrap nopeer noquery
          - 213.95.151.123 nomodify notrap nopeer noquery
          - 62.128.1.18 nomodify notrap nopeer noquery
          - 129.143.2.23 nomodify notrap nopeer noquery
          - 213.239.239.164 nomodify notrap nopeer noquery
          - 10.0.0.0 mask 255.0.0.0 kod nomodify notrap nopeer
          - '2620:0113:: mask ffff:ffff:: kod nomodify notrap nopeer'
          - 149.44.0.0 mask 255.255.0.0 kod nomodify notrap nopeer noquery
          - 149.44.176.0 mask 255.255.248.0 kod nomodify notrap nopeer
          - 192.168.0.0 mask 255.255.255.0  kod nomodify notrap nopeer noquery
          - 192.168.10.0 mask 255.255.255.0 kod nomodify notrap nopeer noquery
          - 192.168.11.0 mask 255.255.255.0 kod nomodify notrap nopeer noquery
        server:
          - 127.127.1.0
          - 130.149.17.21 iburst
          - 131.188.3.220 iburst prefer
          - 131.188.3.221 iburst prefer
          - 131.188.3.222 iburst prefer
          - 213.95.151.123 iburst
          - 62.128.1.18 iburst
          - 129.143.2.23 iburst
          - 213.239.239.164 iburst prefer

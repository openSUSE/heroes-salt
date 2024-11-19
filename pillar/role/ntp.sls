chrony:
  allow:
    - ::1
    - 2a07:de40:617e::/48       # SLC1
    - 2a07:de40:b27e::/48       # PRG2
    - 2a07:de40:b280:86::/64    # daffy
    - fd03:7bbf:d626:1700::/64  # SLC1 os-avalon
    - fda1:21af:580f:1::/127    # SLC1 S2S P2P Avalon1 -> Asgard1
    - fda1:21af:580f:1::2/127   # SLC1 S2S P2P Avalon2 -> Asgard2
  pool:
    {#- only using 2 as {0,1,3} only serve A records
        see https://community.ntppool.org/t/the-time-has-come-we-must-enable-ipv6-entirely/1968/45 #}
    - 2.opensuse.pool.ntp.org
  otherparams:
    - makestep -1 1

chrony:
  allow:
    - ::1
    - 2a07:de40:b27e::/48
    - 2a07:de40:b280:86::/64  # daffy
  pool:
    {#- only using 2 as {0,1,3} only serve A records
        see https://community.ntppool.org/t/the-time-has-come-we-must-enable-ipv6-entirely/1968/45 #}
    - 2.opensuse.pool.ntp.org
  otherparams:
    - makestep -1 1

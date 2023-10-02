chrony:
  allow:
    - 127.0.0.0/8
    - 192.168.47.0/24
  ntpservers:
    - ntp1.opensuse.org
    - ntp2.opensuse.org
  otherparams:
    - makestep -1 1

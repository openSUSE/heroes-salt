zypper:
  repositories:
    repo-oss:
      baseurl: https://download.opensuse.org/distribution/leap/42.1/repo/oss
      priority: 99
      refresh: False
    repo-update-oss:
      baseurl: https://download.opensuse.org/update/leap/42.1/oss
      priority: 99
      refresh: True
    SUSE:CA:
      baseurl: http://smt-internal.opensuse.org/int-suse-ca/openSUSE_Leap_42.1
      gpgautoimport: True
      priority: 99
      refresh: True

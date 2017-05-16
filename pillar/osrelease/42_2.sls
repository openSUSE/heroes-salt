zypper:
  repositories:
    repo-oss:
      baseurl: http://download.infra.opensuse.org/distribution/leap/42.2/repo/oss
      priority: 99
      refresh: False
    repo-update-oss:
      baseurl: http://download.infra.opensuse.org/update/leap/42.2/oss
      priority: 99
      refresh: True
    SUSE:CA:
      baseurl: http://smt-internal.infra.opensuse.org/int-suse-ca/openSUSE_Leap_42.2
      gpgautoimport: True
      priority: 99
      refresh: True

zypper:
  repositories:
    repo-oss:
      baseurl: http://download.infra.opensuse.org/distribution/leap/42.3/repo/oss
      priority: 99
      # TODO: disable refresh after 42.3 release
      refresh: True
    repo-update-oss:
      baseurl: http://download.infra.opensuse.org/update/leap/42.3/oss
      priority: 99
      refresh: True
    SUSE:CA:
      baseurl: http://smt-internal.infra.opensuse.org/int-suse-ca/openSUSE_Leap_42.3
      gpgautoimport: True
      priority: 99
      refresh: True

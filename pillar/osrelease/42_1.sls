zypper:
  repositories:
    openSUSE:infrastructure:
      baseurl: http://download.opensuse.org/repositories/openSUSE:/infrastructure/openSUSE_Leap_42.1
      gpgcheck: 0
      priority: 100
      refresh: True
    repo-oss:
      baseurl: http://download.opensuse.org/distribution/leap/42.1/repo/oss
      priority: 99
      refresh: True
    repo-update-oss:
      baseurl: http://download.opensuse.org/update/leap/42.1/oss
      priority: 99
      refresh: True

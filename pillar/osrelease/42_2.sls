zypper:
  repositories:
    openSUSE:infrastructure:
      baseurl: http://download.opensuse.org/repositories/openSUSE:/infrastructure/openSUSE_Leap_42.2
      priority: 100
      refresh: True
    repo-oss:
      baseurl: http://download.opensuse.org/distribution/leap/42.2/repo/oss
      priority: 99
      refresh: True
    repo-update-oss:
      baseurl: http://download.opensuse.org/update/leap/42.2/oss
      priority: 99
      refresh: True

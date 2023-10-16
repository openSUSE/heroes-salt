zypper:
  packages:
    mlocate: {}
  repositories:
    repo-oss:
      baseurl: http://download.infra.opensuse.org/distribution/leap/$releasever/repo/oss/
      priority: 99
      refresh: False
    repo-update-oss:
      baseurl: http://download.infra.opensuse.org/update/leap/$releasever/oss/
      priority: 99
      refresh: True
    # this is a default repository on Leap, but we currently do not need any packages from it
    #repo-backports-update:
    #  baseurl: http://download.infra.opensuse.org/update/leap/$releasever/backports/
    #  priority: 99
    #  refresh: True
    repo-sle-update:
      baseurl: http://download.infra.opensuse.org/update/leap/$releasever/sle/
      priority: 99
      refresh: True

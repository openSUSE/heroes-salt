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

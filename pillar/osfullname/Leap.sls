limits:
  users:
    '*':
      - limit_type: hard
        limit_item: nproc
        limit_value: 1700
      - limit_type: soft
        limit_item: nproc
        limit_value: 1200
    root:
      - limit_type: hard
        limit_item: nproc
        limit_value: 3000
      - limit_type: soft
        limit_item: nproc
        limit_value: 1850

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

{% set osrelease = salt['grains.get']('osrelease') %}

zypper:
  repositories:
    repo-oss:
      baseurl: http://download.infra.opensuse.org/distribution/leap/{{ osrelease }}/repo/oss
      priority: 99
      refresh: False
    repo-update-oss:
      baseurl: http://download.infra.opensuse.org/update/leap/{{ osrelease }}/oss
      priority: 99
      refresh: True

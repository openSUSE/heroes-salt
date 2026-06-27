zypper:
  repositories:
    repo-oss:
      baseurl: http://$mirror_int/tumbleweed/repo/oss/
      priority: 99
      refresh: True
    repo-update:
      baseurl: http://$mirror_int/update/tumbleweed/
      priority: 99
      refresh: True
    openSUSE:infrastructure:
      baseurl: http://$mirror_int/repositories/openSUSE:/infrastructure/openSUSE_Tumbleweed/
      gpgautoimport: True
      priority: 100
      refresh: True

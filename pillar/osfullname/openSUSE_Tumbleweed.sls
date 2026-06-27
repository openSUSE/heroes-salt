zypper:
  repositories:
    repo-oss:
      baseurl: http://$mirror_int/tumbleweed/repo/oss/
      gpgkey: http://$mirror_int/tumbleweed/repo/oss/repodata/repomd.xml.key
      priority: 99
      refresh: True
    repo-update:
      baseurl: http://$mirror_int/update/tumbleweed/
      gpgkey: http://$mirror_int/update/tumbleweed/repodata/repomd.xml.key
      priority: 99
      refresh: True
    openSUSE:infrastructure:
      baseurl: http://$mirror_int/repositories/openSUSE:/infrastructure/openSUSE_Tumbleweed/
      gpgkey: http://$mirror_int/repositories/openSUSE:/infrastructure/openSUSE_Tumbleweed/repodata/repomd.xml.key
      gpgautoimport: True
      priority: 100
      refresh: True

zypper:
  repositories:
    openSUSE:infrastructure:
      baseurl: http://$mirror_int/repositories/openSUSE:/infrastructure/openSUSE_Tumbleweed/
      gpgautoimport: True
      priority: 100
      refresh: True

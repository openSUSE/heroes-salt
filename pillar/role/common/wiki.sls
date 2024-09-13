zypper:
  repositories:
    openSUSE:infrastructure:wiki:
      baseurl: http://$mirror_int/repositories/openSUSE:/infrastructure:/wiki/$releasever/
      gpgcheck: 0
      priority: 100
      refresh: True

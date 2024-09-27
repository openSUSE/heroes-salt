# service configuration missing :-/

zypper:
  repositories:
    openSUSE:infrastructure:step-ca:
      baseurl: http://$mirror_int/repositories/openSUSE:/infrastructure:/step-ca/$releasever/
      priority: 98
      refresh: true

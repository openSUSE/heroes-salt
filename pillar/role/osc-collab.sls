include:
  - role.common.nginx

zypper:
  repositories:
    openSUSE:infrastructure:osc-collab:
      baseurl: http://$mirror_int/repositories/openSUSE:/infrastructure:/osc-collab/$releasever/
      priority: 99
      refresh: true

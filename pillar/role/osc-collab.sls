include:
  - role.common.nginx

zypper:
  repositories:
    openSUSE:infrastructure:osc-collab:
      baseurl: http://download.infra.opensuse.org/repositories/openSUSE:/infrastructure:/osc-collab/$releasever/
      priority: 99
      refresh: true

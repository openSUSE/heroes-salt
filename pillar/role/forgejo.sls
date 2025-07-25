apparmor:
  local:
    forgejo:
      - /etc/ssl/services/code-dev.infra.opensuse.org/fullchain.pem r
      - /etc/ssl/services/code-dev.infra.opensuse.org/privkey.pem r

zypper:
  repositories:
    openSUSE:infrastructure:forgejo:
      baseurl: http://$mirror_int/repositories/openSUSE:/infrastructure:/forgejo/$releasever/
      priority: 100
      refresh: True

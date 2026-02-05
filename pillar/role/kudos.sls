# Awesome KUDOS Recognition app

zypper:
  packages:
    kudos: {}
    kudos-badges: {}

  repositories:
    openSUSE:infrastructure:kudos:
      baseurl: http://$mirror_int/repositories/openSUSE:/infrastructure:/kudos/$releasever/
      priority: 98
      refresh: True

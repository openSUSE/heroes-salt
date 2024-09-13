zypper:
  repositories:
    repo-oss:
      baseurl: http://$mirror_int/distribution/leap/$releasever/repo/oss/
      priority: 99
      refresh: False
    repo-update-oss:
      baseurl: http://$mirror_int/update/leap/$releasever/oss/
      priority: 99
      refresh: True
    repo-backports-update:
      baseurl: http://$mirror_int/update/leap/$releasever/backports/
      priority: 99
      refresh: True
    repo-sle-update:
      baseurl: http://$mirror_int/update/leap/$releasever/sle/
      priority: 99
      refresh: True
    openSUSE:infrastructure:
      baseurl: http://$mirror_int/repositories/openSUSE:/infrastructure/$releasever/
      gpgautoimport: True
      priority: 100
      refresh: True
    {%- if grains['virtual'] == 'physical' %}
    openSUSE:infrastructure:physical:
      baseurl: http://$mirror_int/repositories/openSUSE:/infrastructure:/physical/$releasever/
      priority: 98
      refresh: True
    {%- endif %}

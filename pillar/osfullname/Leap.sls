zypper:
  repositories:
    repo-oss:
      baseurl: http://$mirror_int/distribution/leap/$releasever/repo/oss/
      gpgkey: http://$mirror_int/distribution/leap/$releasever/repo/oss/repodata/repomd.xml.key
      priority: 99
      refresh: False
    {%- if grains['osrelease'] | float < 16 %}
    repo-update-oss:
      baseurl: http://$mirror_int/update/leap/$releasever/oss/
      gpgkey: http://$mirror_int/update/leap/$releasever/oss/repodata/repomd.xml.key
      priority: 99
      refresh: True
    repo-backports-update:
      baseurl: http://$mirror_int/update/leap/$releasever/backports/
      gpgkey: http://$mirror_int/update/leap/$releasever/backports/repodata/repomd.xml.key
      priority: 99
      refresh: True
    repo-sle-update:
      baseurl: http://$mirror_int/update/leap/$releasever/sle/
      gpgkey: http://$mirror_int/update/leap/$releasever/sle/repodata/repomd.xml.key
      priority: 99
      refresh: True
    {%- endif %}
    openSUSE:infrastructure:
      baseurl: http://$mirror_int/repositories/openSUSE:/infrastructure/$releasever/
      gpgkey: http://$mirror_int/repositories/openSUSE:/infrastructure/$releasever/repodata/repomd.xml.key
      gpgautoimport: True
      priority: 100
      refresh: True
    {%- if grains['virtual'] == 'physical' %}
    openSUSE:infrastructure:physical:
      baseurl: http://$mirror_int/repositories/openSUSE:/infrastructure:/physical/$releasever/
      priority: 98
      refresh: True
    {%- endif %}

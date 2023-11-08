{%- from 'osfullname/map.jinja' import mirror %}

zypper:
  repositories:
    repo-oss:
      baseurl: http://{{ mirror }}/distribution/leap/$releasever/repo/oss/
      priority: 99
      refresh: False
    repo-update-oss:
      baseurl: http://{{ mirror }}/update/leap/$releasever/oss/
      priority: 99
      refresh: True
    repo-backports-update:
      baseurl: http://{{ mirror }}/update/leap/$releasever/backports/
      priority: 99
      refresh: True
    repo-sle-update:
      baseurl: http://{{ mirror }}/update/leap/$releasever/sle/
      priority: 99
      refresh: True
    openSUSE:infrastructure:
      {%- if grains.get('osrelease') in ('15.2', '15.3') %}
      baseurl: http://{{ mirror }}/repositories/openSUSE:/infrastructure/openSUSE_Leap_$releasever/
      {%- else %}
      baseurl: http://{{ mirror }}/repositories/openSUSE:/infrastructure/$releasever/
      {%- endif %}
      gpgautoimport: True
      priority: 100
      refresh: True

{%- from 'osfullname/map.jinja' import mirror %}

zypper:
  repositories:
    openSUSE:infrastructure:
      baseurl: http://{{ mirror }}/repositories/openSUSE:/infrastructure/openSUSE_Tumbleweed/
      gpgautoimport: True
      priority: 100
      refresh: True

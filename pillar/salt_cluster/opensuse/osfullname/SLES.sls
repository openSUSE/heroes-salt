{% set osrelease_info = salt['grains.get']('osrelease_info') %}

{% set version = osrelease_info[0]|string %}
{% if osrelease_info|length == 2 %}
    {% set version = version + '_SP' + osrelease_info[1]|string %}
{% endif %}

zypper:
  repositories:
    openSUSE:infrastructure:
      baseurl: https://download.infra.opensuse.org/repositories/openSUSE:/infrastructure/SLE_{{ version }}
      gpgautoimport: True
      priority: 100
      refresh: True

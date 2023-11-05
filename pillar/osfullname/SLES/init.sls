{%- set osmajorrelease = salt['grains.get']('osmajorrelease')|int %}
{%- from slspath ~ '/map.jinja' import leap_equivalent %}

include:
  - .{{ osmajorrelease }}

zypper:
  repositories:
    openSUSE:infrastructure:
      baseurl: https://download.infra.opensuse.org/repositories/openSUSE:/infrastructure/{{ leap_equivalent }}/
      gpgautoimport: True
      priority: 100
      refresh: True

{%- from 'osfullname/map.jinja' import mirror %}

{%- set osri = grains['osrelease_info'] %}
{%- if osri[0] == 5 %}
{%- set leap_equivalent = '15' ~ '.' ~ ( osri[1] + 1 ) | string %}
zypper:
  repositories:
    openSUSE:infrastructure:
      baseurl: http://{{ mirror }}/repositories/openSUSE:/infrastructure/{{ leap_equivalent }}/
      gpgautoimport: True
      priority: 100
      refresh: True
    openSUSE:infrastructure:Micro:
      baseurl: http://{{ mirror }}/repositories/openSUSE:/infrastructure:/Micro/Micro_{{ grains['osrelease'] }}/
      gpgautoimport: True
      priority: 98
      refresh: True
{%- else %}
{%- do salt.log.warning('Unsupported SLE/Leap Micro release') %}
{%- endif %}

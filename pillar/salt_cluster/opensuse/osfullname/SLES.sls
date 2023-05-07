{% set osrelease_info = salt['grains.get']('osrelease_info') %}

{%- if osrelease_info[0] < 15 %}
{% set version = osrelease_info[0]|string %}
{% if osrelease_info|length == 2 %}
    {% set version = version + '_SP' + osrelease_info[1]|string %}
{%- endif %}
{%- set repo_version = 'SLE_' ~ version %}
{%- else %}
{%- set repo_version = salt['grains.get']('osrelease') %}
{% endif %}

zypper:
  repositories:
    openSUSE:infrastructure:
      baseurl: https://download.infra.opensuse.org/repositories/openSUSE:/infrastructure/{{ repo_version }}/
      gpgautoimport: True
      priority: 100
      refresh: True

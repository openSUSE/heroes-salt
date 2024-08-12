include:
  - ssh_keys.groups.download_infra
  - secrets.mirrorcache

zypper:
  repositories:
    mc:
      baseurl: http://download-prv.infra.opensuse.org/repositories/openSUSE:/infrastructure:/MirrorCache/$releasever/
      priority: 100
      refresh: False
      gpgautoimport: True


{% set site = salt['grains.get']('site') %}

{%- if site == 'prv1' %}

mirrorcache:
  redirect: downloadcontentcdn.opensuse.org
  redirect_huge: downloadcontent.opensuse.org
  db:
    host: 192.168.67.23

mysql:
  user:
    mirrorcache:
      host: 192.168.67.%
      # password is set in pillar/secrets/mirrorcache

{%- endif %}

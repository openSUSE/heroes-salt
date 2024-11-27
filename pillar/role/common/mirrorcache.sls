include:
  - secrets.mirrorcache

zypper:
  repositories:
    mc:
      baseurl: http://$mirror_int/repositories/openSUSE:/infrastructure:/MirrorCache/$releasever/
      priority: 100
      refresh: False
      gpgautoimport: True


{% set site = salt['grains.get']('site') %}

{%- if site == 'slc1' %}

mirrorcache:
  redirect: downloadcontentcdn.opensuse.org
  redirect_huge: downloadcontent.opensuse.org
  db:
    host: mirrorcache-us-db.infra.opensuse.org

mysql:
  user:
    mirrorcache:
      host: 2a07:de40:617e:1906::a
      # password is set in pillar/secrets/mirrorcache

{%- endif %}

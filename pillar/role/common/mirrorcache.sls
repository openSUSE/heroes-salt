include:
  - secrets.role.common.mirrorcache

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
      hosts:
        - 2a07:de40:617e:1906::a  # mirrorcache-us.i.o.o, no PTR yet
        - mirrorcache-us-db.infra.opensuse.org
      # password is set in pillar/secrets/mirrorcache

{%- endif %}


zypper:
  repositories:
    mc:
      baseurl: http://download.infra.opensuse.org/repositories/openSUSE:/infrastructure:/MirrorCache/$releasever/
      priority: 100
      refresh: False
      gpgautoimport: True


{% set country = salt['grains.get']('country') %}

{% if country == 'de' %} 

mirrorcache:
  redirect: downloadcontent.opensuse.org
  root_nfs: /mnt
  db:
    host: 192.167.47.47

mysql:
  user:
    mirrorcache:
      host: 192.168.47.%
      # password is set in pillar/secrets/mirrorcache

{% elif country == 'us' %} 

mirrorcache:
  redirect: downloadcontent-us1.opensuse.org
  redirect_huge: downloadcontent.opensuse.org
  db:
    host: 192.168.67.23

mysql:
  user:
    mirrorcache:
      host: 192.168.67.%
      # password is set in pillar/secrets/mirrorcache

{% endif %}

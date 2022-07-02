sudoers:
  included_files:
    /etc/sudoers.d/group_wiki-admins:
      groups:
        wiki-admins:
          - 'ALL=(ALL) ALL'

zypper:
  repositories:
    openSUSE:infrastructure:wiki:
      {% if grains.get('osrelease') == '15.3' %}
      baseurl: http://download.infra.opensuse.org/repositories/openSUSE:/infrastructure:/wiki/openSUSE_Leap_$releasever/
      {% else %}
      baseurl: http://download.infra.opensuse.org/repositories/openSUSE:/infrastructure:/wiki/$releasever/
      {% endif %}
      gpgcheck: 0
      priority: 100
      refresh: True

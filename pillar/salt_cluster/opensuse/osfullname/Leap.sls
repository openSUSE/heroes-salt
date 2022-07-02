zypper:
  repositories:
    openSUSE:infrastructure:
      {% if grains.get('osrelease') in ('15.2', '15.3') %}
      baseurl: http://download.infra.opensuse.org/repositories/openSUSE:/infrastructure/openSUSE_Leap_$releasever/
      {% else %}
      baseurl: http://download.infra.opensuse.org/repositories/openSUSE:/infrastructure/$releasever/
      {% endif %}
      gpgautoimport: True
      priority: 100
      refresh: True

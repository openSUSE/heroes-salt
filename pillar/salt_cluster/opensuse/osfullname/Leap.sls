zypper:
  repositories:
    openSUSE:infrastructure:
      baseurl: http://download.infra.opensuse.org/repositories/openSUSE:/infrastructure/openSUSE_Leap_{{ salt['grains.get']('osrelease') }}
      gpgautoimport: True
      priority: 100
      refresh: True

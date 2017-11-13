sudoers:
  included_files:
    /etc/sudoers.d/group_wiki-admins:
      groups:
        wiki-admins:
          - 'ALL=(ALL) ALL'

zypper:
  repositories:
    openSUSE:infrastructure:wiki:
      baseurl: http://download.infra.opensuse.org/repositories/openSUSE:/infrastructure:/wiki/openSUSE_Leap_{{ salt['grains.get']('osrelease') }}/
      gpgcheck: 0
      priority: 100
      refresh: True

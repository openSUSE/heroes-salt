{% if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.identification
{% endif %}


profile:
  identification:
    database_user: identification
    database_host: postgresql.infra.opensuse.org

sudoers:
  included_files:
    /etc/sudoers.d/group_ipsilon-admins:
      groups:
        ipsilon-admins:
          - 'ALL=(ALL) ALL'

zypper:
  repositories:
    openSUSE:infrastructure:ipsilon:
      baseurl: http://download.infra.opensuse.org/repositories/openSUSE:/infrastructure:/ipsilon/openSUSE_Leap_$releasever/
      priority: 100
      refresh: True

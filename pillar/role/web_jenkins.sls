include:
  - role.common.nginx

sudoers:
  included_files:
    /etc/sudoers.d/group_jenkins-admins:
      groups:
        jenkins-admins:
          - 'ALL=(ALL) ALL'

zypper:
  repositories:
    devel:tools:building:
      baseurl: http://download.opensuse.org/repositories/devel:/tools:/building/$releasever/
      priority: 100
      refresh: True

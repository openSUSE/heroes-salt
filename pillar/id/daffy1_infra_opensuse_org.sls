grains:
  city: nuremberg
  country: de
  hostusage:
    - login2.o.o
  reboot_safe: unknown
  salt_cluster: opensuse
  virt_cluster: atreju

  aliases: []
  description: Login proxy for servers with authentication
  documentation:
    # should/will be moved to a "loginproxy" page (or to the login role ;-)
    - https://progress.opensuse.org/projects/opensuse-admin-wiki/wiki/Daffy1infraopensuseorg
  responsible: []
  partners:
    - daffy2.infra.opensuse.org
  weburls:
    - https://login2.opensuse.org
roles:
  - ha
  - login
  - login_master

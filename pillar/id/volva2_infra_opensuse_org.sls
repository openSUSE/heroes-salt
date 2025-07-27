grains:
  site: slc1
  hostusage:
    - Salt Master
  reboot_safe: yes
  aliases:
    - slc-salt2.infra.opensuse.org
  description: Salt Master
  documentation: []
  responsible: []
  partners:
    - volva1.infra.opensuse.org
  weburls: []
infrastructure:
  salt:
    scriptconfig:
      partner: volva1.infra.opensuse.org
profile:
  authorized-exec:
    salt:
      root:
        pubkey: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEOFnaLBJbh3wso38lYUOHcdj406o7pj7rK+uprIrEzi
roles:
  - salt.master
  - salt.syndic
users:
  root:
    ssh_auth_file:
      - command="authorized-exec /etc/authorized-exec/salt",restrict ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEOFnaLBJbh3wso38lYUOHcdj406o7pj7rK+uprIrEzi root@volva1

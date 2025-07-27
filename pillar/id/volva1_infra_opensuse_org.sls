grains:
  site: slc1
  hostusage:
    - Salt Master
  reboot_safe: yes
  aliases:
    - slc-salt1.infra.opensuse.org
  description: Salt Master
  documentation: []
  responsible: []
  partners:
    - volva2.infra.opensuse.org
  weburls: []
infrastructure:
  salt:
    scriptconfig:
      partner: volva2.infra.opensuse.org
profile:
  authorized-exec:
    salt:
      root:
        pubkey: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL7UPDbosNAcIVOavTLjQh56G2jw3Ui9J+t9iPolHZyL
roles:
  - salt.master
  - salt.syndic
users:
  root:
    ssh_auth_file:
      - command="authorized-exec /etc/authorized-exec/salt",restrict ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL7UPDbosNAcIVOavTLjQh56G2jw3Ui9J+t9iPolHZyL root@volva2

users:
  cert:
    fullname: Certificate Deployment User
    shell: /bin/sh
    ssh_auth_file:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOXfogRapqcAJJOe1S+EYSrFLeNN+1MxDHnfav443GaM dehydrated@acme

sudoers:
  users:
    cert:
      - '{{ grains['host'] }}=(root) NOPASSWD: /usr/bin/systemctl reload haproxy'

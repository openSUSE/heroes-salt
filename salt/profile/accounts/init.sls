include:
  - limits
  - openssh
  - openssh.banner
  - openssh.config
  - sudoers
  - sudoers.included
  - users

/etc/bash.bashrc.local:
  file.managed:
    - source: salt://profile/accounts/files/etc/bash.bashrc.local.jinja
    - template: jinja

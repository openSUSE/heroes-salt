include:
  - limits
  - openssh
  - openssh.banner
  - openssh.config
  - sudoers
  - sudoers.included

/etc/bash.bashrc.local:
  file.managed:
    - source: salt://profile/files/etc/bash.bashrc.local.jinja
    - template: jinja

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

/etc/profile.local:
  file.managed:
    - source: salt://profile/accounts/files/etc/profile.local.jinja
    - template: jinja

/etc/skel:
  file.recurse:
    - source: salt://profile/accounts/files/etc/skel

/root/.digrc:
  file.managed:
    - source: salt://profile/accounts/files/etc/skel/.digrc

sudoers:
  users:
    osem:
      - 'ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart osem-dj'
      - 'ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart osem'

zypper:
  repositories:
    devel:languages:ruby:
      baseurl: https://$mirror_int/repositories/devel:/languages:/ruby/$releasever/
      priority: 100
      refresh: True

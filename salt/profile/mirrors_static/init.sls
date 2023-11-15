mirrors_static:
    user.present:
    - createhome: False
    - home: /home/mirrors_static
    - shell: /bin/bash

mirrors_static_root_owned_dirs:
  file.directory:
    - names:
      - /home/mirrors_static
      - /home/mirrors_static/.ssh
      - /home/mirrors_static/bin
    - user: root

mirrors_static_owned_dirs:
  file.directory:
    - names:
      - /home/mirrors_static/wget
      - /home/mirrors_static/git
    - user: mirrors_static

/home/mirrors_static/.ssh/id_rsa:
  file.managed:
    - contents_pillar: profile:mirrors_static:sshkey
    - mode: 600
    - user: mirrors_static

/home/mirrors_static/.ssh/known_hosts:
  file.managed:
    - contents_pillar:
      - managed_by_salt
      - profile:mirrors_static:ssh_known_hosts
    - mode: 644
    - user: root

mirrors_static_cron_mailto:
  cron.env_present:
    - name: MAILTO
    - value: admin-auto@opensuse.org
    - user: mirrors_static

/home/mirrors_static/bin/git_push_mirrors_static:
  cron.present:
    - user: mirrors_static
    - minute: 55
  file.managed:
    - mode: 755
    - source: salt://profile/mirrors_static/files/git_push_mirrors_static.sh
    - user: root

mirrors_static_main:
  git.cloned:
    - name: https://github.com/openSUSE/mirrors-static
    - target: /home/mirrors_static/git/mirrors_static
    - branch: main
    - user: mirrors_static

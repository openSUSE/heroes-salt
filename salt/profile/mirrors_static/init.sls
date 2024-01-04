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
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        {%- for entry in salt['pillar.get']('profile:mirrors_static:ssh_known_hosts') %}
        - {{ entry }}
        {%- endfor %}
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

{% set repo_path = '/home/mirrors_static/git/mirrors_static' %}

mirrors_static_clone_repo:
  git.cloned:
    - name: git@github.com:openSUSE/mirrors-static.git
    - target: {{ repo_path }}
    - branch: main
    - user: mirrors_static
    - identity: /home/mirrors_static/.ssh/id_rsa

{% set host_id = salt['grains.get']('id') %}

mirrors_static_git_config_name:
  git.config_set:
    - name: user.name
    - value: mirrors_static
    - repo: {{ repo_path }}
    - user: mirrors_static

mirrors_static_git_config_email:
  git.config_set:
    - name: user.email
    - value: mirrors_static@{{ host_id }}
    - repo: {{ repo_path }}
    - user: mirrors_static

mirrors_static_git_config_remote:
  git.config_set:
    - name: branch.main.remote
    - value: origin
    - repo: {{ repo_path }}
    - user: mirrors_static

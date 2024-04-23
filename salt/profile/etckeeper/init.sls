include:
  - zypper.packages

etckeeper_init:
  cmd.run:
    - name: etckeeper init
    - creates: /etc/.git
    - require:
        - pkg: zypper_packages

etckeeper_timer:
  service.running:
    - name: etckeeper.timer
    - enable: True

etckeeper_git_config_name:
  git.config_set:
    - name: user.name
    - value: etckeeper
    - repo: /etc
    - require:
        - pkg: zypper_packages

etckeeper_git_config_email:
  git.config_set:
    - name: user.email
    - value: etckeeper@{{ salt['grains.get']('id') }}
    - repo: /etc
    - require:
        - pkg: zypper_packages

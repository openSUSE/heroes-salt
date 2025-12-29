salt_git-config:
  git.config_set:
    - names:
        - user.name:
            - value: 'Salt Automation - {{ grains['id'] }}'
        - user.email:
            - value: admin-auto@opensuse.org
    - global: true
    - user: salt

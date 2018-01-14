/etc/sudoers.d/gitlab-runner_nopasswd_saltmaster_deploy:
  file.managed:
    - source: salt://profile/gitlab_runner/files/etc/sudoers.d/gitlab-runner_nopasswd_saltmaster_deploy
    - template: jinja
    - mode: 440

gitlab_runner_packages:
  pkg.installed:
    - pkgs:
      - git-core

gitlab_runner:
  pkg.installed:
    - name: gitlab-runner
  service.running:
    - name: gitlab-runner
    - enable: True
    - watch:
        - pkg: gitlab-runner

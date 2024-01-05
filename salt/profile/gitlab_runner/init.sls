include:
  - .cleanup

profile_gitlab_runner_package:
  pkg.installed:
    - name: gitlab-runner

profile_gitlab_runner_config:
  file.serialize:
    - name: /etc/gitlab-runner/config.toml
    - serializer: toml
    - dataset_pillar: profile:gitlab_runner:config
    - require:
        - pkg: profile_gitlab_runner_package

profile_gitlab_runner_service:
  service.running:
    - name: gitlab-runner
    - enable: True
    - watch:
        - file: profile_gitlab_runner_config
    - require:
        - pkg: profile_gitlab_runner_package

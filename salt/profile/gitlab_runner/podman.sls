profile_gitlab_runner_podman_package:
  pkg.installed:
    - pkgs:
        - podman
        - cni
        - cni-plugins

profile_gitlab_runner_podman_config:
  file.managed:
    - name: /etc/containers/containers.conf
    - source: salt://{{ slspath }}/files//etc/containers/containers.conf.jinja
    - template: jinja
    - require:
        - pkg: profile_gitlab_runner_podman_package

profile_gitlab_runner_podman_socket:
  service.running:
    - name: podman.socket
    - enable: true
    - require:
        - pkg: profile_gitlab_runner_podman_package

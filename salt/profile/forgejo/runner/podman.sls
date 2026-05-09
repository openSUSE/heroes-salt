profile_forgejo_runner_podman_packages:
  pkg.installed:
    - pkgs:
        - podman
        - cni
        - cni-plugins

profile_forgejo_runner_podman_config:
  file.managed:
    - name: /etc/containers/containers.conf
    - source: salt://profile/forgejo/files/etc/containers/containers.conf.jinja
    - template: jinja
    - require:
        - pkg: profile_forgejo_runner_podman_packages

profile_forgejo_runner_podman_socket:
  service.running:
    - name: podman.socket
    - enable: true
    - require:
        - pkg: profile_forgejo_runner_podman_packages

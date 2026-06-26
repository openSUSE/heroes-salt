include:
  - .cleanup
  - .podman

profile_forgejo_runner_packages:
  pkg.installed:
    - names:
        - forgejo-runner

profile_forgejo_runner_config:
  file.managed:
    - name: /etc/forgejo-runner/config.yaml
    - user: root
    - group: root
    - mode: '0640'
    - source: salt://profile/forgejo/files/etc/forgejo-runner/config.yaml.jinja
    - template: jinja
    - require:
        - pkg: profile_forgejo_runner_packages

profile_forgejo_runner_service:
  service.running:
    - name: forgejo-runner
    - enable: true
    - require:
        - pkg: profile_forgejo_runner_packages
    - watch:
        - file: profile_forgejo_runner_config

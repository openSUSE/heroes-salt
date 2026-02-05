include:
  - zypper.packages

profile_kudos_directory:
  file.directory:
    - name: /data/kudos
    - user: kudos
    - group: kudos

kudos_service:
  service.running:
    - name: kudos
    - enable: true
    - reload: true
    - require:
        - pkg: zypper_packages

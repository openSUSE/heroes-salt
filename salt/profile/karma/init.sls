profile_karma_packages:
  pkg.installed:
    - name: karma

profile_karma_config:
  file.serialize:
    - name: /etc/karma/config.yaml
    - serializer: yaml
    - dataset_pillar: profile:karma
    - require:
        - pkg: profile_karma_packages

profile_karma_service:
  service.running:
    - name: karma
    - enable: true
    - require:
        - pkg: profile_karma_packages
    - watch:
        - file: profile_karma_config

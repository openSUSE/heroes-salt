profile_sample-webapp_packages:
  pkg.installed:
    - name: sample-go-webapp

profile_sample-webapp_config:
  file.serialize:
    - name: /etc/sample-go-webapp.json
    - dataset_pillar: profile:sample-webapp:config
    - serializer: json
    - user: root
    - group: root
    - mode: '0640'

profile_sample-webapp_service:
  service.running:
    - name: sample-go-webapp
    - reload: false
    - watch:
        - file: profile_sample-webapp_config
    - require:
        - pkg: profile_sample-webapp_packages

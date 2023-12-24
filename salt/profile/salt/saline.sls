/etc/salt/saline.d/restapi.conf:
  file.serialize:
    - serializer: yaml
    - dataset: {{ {'restapi': salt['pillar.get']('profile:salt:saline:restapi')} }}

salined:
  service.running:
    - enable: true
    - watch:
      - file: /etc/salt/saline.d/restapi.conf

/etc/salt/saline.d/restapi.conf:
  file.serialize:
    - serializer: yaml
    - dataset: {{ {'restapi': salt['pillar.get']('profile:salt:saline:restapi')} }}

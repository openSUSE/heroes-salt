/etc/salt/saline.d/restapi.conf:
  file.serialize:
    - serializer: yaml
    - dataset_pillar: profile:salt:saline:restapi

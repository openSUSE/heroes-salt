include:
  - elasticsearch


# enforce that elasticsearch only starts if the AppArmor profile is loaded
/etc/systemd/system/elasticsearch.service.d:
  file.directory

/etc/systemd/system/elasticsearch.service.d/es-apparmor.conf:
  file.managed:
    - contents:
      - '[Service]'
      - AppArmorProfile=elasticsearch
    - require_in:
      - elasticsearch
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/elasticsearch.service.d/es-apparmor.conf

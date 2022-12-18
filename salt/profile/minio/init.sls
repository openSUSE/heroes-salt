minio_dependencies:
  pkg.installed:
    - pkgs:
      - minio

minio_default_file:
  file.managed:
    - name: /etc/default/minio
    - source: salt://profile/minio/files/default
    - template: jinja
    - require_in:
      - service: minio_service
    - watch_in:
      - module: minio_restart

minio_service:
  service.running:
    - name: minio.service
    - enable: True

minio_restart:
  module.wait:
    - name: service.restart
    - m_name: minio.service
    - require:
      - service: minio_service

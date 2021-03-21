synapse_dependencies:
  pkg.installed:
    - pkgs:
      - matrix-synapse

synapse:
  group.present:
    - system: True
    - members:
      - synapse

synapse_systemd_file:
  file.managed:
    - name: /etc/systemd/system/synapse.service
    - source: salt://profile/matrix/files/synapse.service
    - require_in:
      - service: synapse_service

synapse_log_dir:
  file.directory:
    - name: /var/log/matrix-synapse/
    - user: synapse
    - group: synapse
    - require_in:
      - service: synapse_service

synapse_data_dir:
  file.directory:
    - name: /var/lib/matrix-synapse/
    - user: synapse
    - group: synapse

synapse_media_store_dir:
  file.directory:
    - name: /var/lib/matrix-synapse/media-store/
    - user: synapse
    - group: synapse
    - require:
      - file: synapse_data_dir
    - require_in:
      - service: synapse_service

synapse_uploads_dir:
  file.directory:
    - name: /var/lib/matrix-synapse/uploads/
    - user: synapse
    - group: synapse
    - require:
      - file: synapse_data_dir
    - require_in:
      - service: synapse_service

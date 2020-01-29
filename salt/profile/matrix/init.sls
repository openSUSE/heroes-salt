{% set roles = salt['grains.get']('roles', []) %}

synapse-service:
  service.running:
    - name: synapse
    - enable: True

synapse-restart:
  module.wait:
    - name: service.restart
    - m_name: synapse
    - require:
      - service: synapse-service

discord_service:
  service.running:
    - name: discord
    - enable: True
    - require:
      - service: synapse_service

discord_restart:
  module.wait:
    - name: service.restart
    - m_name: discord
    - require:
      - service: synapse_service
      - service: discord_service

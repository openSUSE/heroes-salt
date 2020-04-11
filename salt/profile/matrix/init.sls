synapse_service:
  service.running:
    - name: synapse
    - enable: True

synapse_restart:
  module.wait:
    - name: service.restart
    - m_name: synapse
    - require:
      - service: synapse_service

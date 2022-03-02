synapse_service:
  service.running:
    - name: matrix-synapse.target
    - enable: True

synapse_restart:
  module.wait:
    - name: service.restart
    - m_name: matrix-synapse.target
    - require:
      - service: synapse_service

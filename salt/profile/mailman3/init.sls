mailman_service:
  service.running:
    - name: mailman
    - enable: True

mailman_restart:
  module.wait:
    - name: service.restart
    - m_name: mailman
    - require:
      - service: mailman_service

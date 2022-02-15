include:
  - profile.mailman3.mailman
  - profile.mailman3.config
  - profile.mailman3.master

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

mailman_hyperkitty_service:
  service.running:
    - name: hyperkitty
    - enable: True

mailman_hyperkitty_restart:
  module.wait:
    - name: service.restart
    - m_name: hyperkitty
    - require:
      - service: mailman_hyperkitty_service

mailman_postorius_service:
  service.running:
    - name: postorius
    - enable: True

mailman_postorius_restart:
  module.wait:
    - name: service.restart
    - m_name: postorius
    - require:
      - service: mailman_postorius_service

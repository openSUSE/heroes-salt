discourse_pgks:
  pkg.installed:
    - pkgs:
      - discourse

discourse_target:
  service.running:
    - name: discourse.target
    - enable: True

discourse_update_service:
  service.running:
    - name: discourse-update
    - enable: True

discourse_puma_service:
  service.running:
    - name: discourse-puma
    - enable: True

discourse_sidekiq_service:
  service.running:
    - name: discourse-puma
    - enable: True

discourse_restart:
  module.wait:
    - name: service.restart
    - m_name: discourse.target
    - require:
      - service: discourse_update_service
      - service: discourse_puma_service
      - service: discourse_sidekiq_service
      - service: discourse_target

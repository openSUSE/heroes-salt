/var/lib/matrix-synapse/dimension:
  file.directory:
    - user: synapse

/var/log/matrix-synapse/dimension:
  file.directory:
    - user: synapse

https://github.com/turt2live/matrix-dimension.git:
  git.latest:
    - branch: master
    - target: /var/lib/matrix-synapse/dimension
    - rev: master
    - user: synapse

dimension_conf_file:
  file.managed:
    - name: /var/lib/matrix-synapse/dimension/config/production.yaml
    - source: salt://profile/matrix/files/config-dimension.yaml
    - template: jinja
    - user: synapse
    - require:
      - file: /var/lib/matrix-synapse/dimension
    - require_in:
      - service: dimension_service
    - watch_in:
      - module: dimension_restart

# dimension_boostrap:
#   cmd.run:
#     - name: npm install
#     - cwd: /var/lib/matrix-synapse/dimension
#     - runas: synapse
#     - env:
#       - NODE_VERSION: 10

# dimension_build:
#   cmd.run:
#     - name: npm run build
#     - cwd: /var/lib/matrix-synapse/dimension
#     - runas: synapse
#     - env:
#       - NODE_VERSION: 10

dimension_systemd_file:
  file.managed:
    - name: /etc/systemd/system/dimension.service
    - template: jinja
    - source: salt://profile/matrix/files/dimension.service
    - require_in:
      - service: dimension_service

dimension_service:
  service.running:
    - name: dimension
    - enable: True
    - require:
      - service: synapse_service

dimension_restart:
  module.wait:
    - name: service.restart
    - m_name: dimension
    - require:
      - service: synapse_service
      - service: dimension_service

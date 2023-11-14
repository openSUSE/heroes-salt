include:
  - .directories

workers_nginx_file:
  file.managed:
    - name: /etc/matrix-synapse/workers/nginx.conf
    - source: salt://profile/matrix/files/workers.nginx
    - template: jinja
    - require:
      - file: matrix_conf_dirs

upstreams_nginx_file:
  file.managed:
    - name: /etc/matrix-synapse/workers/upstreams.conf
    - source: salt://profile/matrix/files/upstreams.nginx
    - template: jinja
    - require:
      - file: matrix_conf_dirs

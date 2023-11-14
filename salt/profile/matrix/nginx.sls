workers_nginx_file:
  file.managed:
    - name: /etc/matrix-synapse/workers/nginx.conf
    - source: salt://profile/matrix/files/workers.nginx
    - template: jinja

upstreams_nginx_file:
  file.managed:
    - name: /etc/matrix-synapse/workers/upstreams.conf
    - source: salt://profile/matrix/files/upstreams.nginx
    - template: jinja

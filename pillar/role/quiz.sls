include:
  - role.common.nginx

nginx:
  servers:
    managed:
      quiz.conf:
        config:
          - map $http_x_forwarded_host $socket:
              - quiz.opensuse.org: main.sock
              - ~^(.+)\.quiz\.opensuse\.org$: $1.sock
          - server:
              - listen: '[::]:443 ssl http2'
              - server_name: quiz.infra.opensuse.org
              - ssl_certificate: /etc/ssl/services/quiz.infra.opensuse.org/fullchain.pem
              - ssl_certificate_key: /etc/ssl/services/quiz.infra.opensuse.org/privkey.pem
              - error_page: 502 /502.html
              - location /check:
                  - root: /srv/www/htdocs
              - location /502.html:
                  - root: /srv/www/htdocs
              - location /:
                  - proxy_pass: http://unix:/run/quiz/$socket
        enabled: True

status-mail:
  services:
    - quiz-update

users:
  quiz:
    fullname: Quiz application user

zypper:
  packages:
    podman: {}
    systemd-container: {}  # for machinectl
    python311-json5: {}    # for salt/profile/quiz/files/deploy-quizzes.py.jinja
    python311-podman: {}   # ^

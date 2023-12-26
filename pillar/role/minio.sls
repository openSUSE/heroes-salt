include:
  {% if salt['grains.get']('include_secrets', True) %}
  - secrets.role.minio
  {% endif %}
  - role.common.nginx

nginx:
  servers:
    managed:
      s3.opensuse-project.net.conf:
        config:
          - server:
              - server_name: s3.opensuse-project.net
              - listen:
                  - '[::]:80'
                  - default_server
              - ignore_invalid_headers: "off"
              - proxy_buffering: "off"
              - location /:
                  - proxy_set_header: X-Real-IP $remote_addr
                  - proxy_set_header: X-Forwarded-For $proxy_add_x_forwarded_for
                  - proxy_set_header: X-Forwarded-Proto $scheme
                  - proxy_set_header: Host $http_host
                  - proxy_connect_timeout: 300
                  - proxy_http_version: 1.1
                  - proxy_set_header: Connection ""
                  - chunked_transfer_encoding: "off"
                  - proxy_redirect: "off"
                  - client_max_body_size: 20M
                  - proxy_pass: http://localhost:9000
        enabled: True

zypper:
  repositories:
    server:database:
      baseurl: https://downloadcontent.opensuse.org/repositories/server:/database/$releasever/
      priority: 100
      refresh: True

include:
  {% if salt['grains.get']('include_secrets', True) %}
  - secrets.role.minio
  {% endif %}
  - role.common.nginx

nginx:
  ng:
    servers:
      managed:
        s3.opensuse-project.net:
          config:
            - upstream minio:
                - server: 127.0.0.1:9000 fail_timeout=0
            - server:
                - server_name: s3.opensuse-project.net
                - listen:
                    - 80
                    - default_server
                - location /:
                    - try_files: $uri @minio
                - location @minio:
                    - proxy_set_header: X-Forwarded-For $proxy_add_x_forwarded_for
                    - proxy_set_header: X-Forwarded-Proto https
                    - proxy_set_header: X-Forwarded-Protocol ssl
                    - proxy_set_header: Host $http_host
                    - proxy_redirect: "off"
                    - client_max_body_size: 2M
                    - proxy_pass: http://minio
          enabled: True

zypper:
  repositories:
    server:database:
      baseurl: http://download.opensuse.org/repositories/server:/database/$releasever/
      priority: 100
      refresh: True

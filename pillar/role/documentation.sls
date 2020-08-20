include:
  - role.common.nginx

nginx:
  ng:
    servers:
      managed:
        doc.opensuse.org.conf:
          config:
            - server:
                - server_name: doc.opensuse.org
                - listen:
                    - 80
                - location /:
                    - root: /srv/www/vhosts/doc.opensuse.org/
          enabled: True

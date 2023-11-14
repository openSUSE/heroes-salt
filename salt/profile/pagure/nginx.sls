pagure_ssl_conf:
  file.managed:
    - name: /etc/nginx/ssl-config
    - source: salt://profile/pagure/files/ssl-config

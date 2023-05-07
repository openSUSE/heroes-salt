haproxy:
  enabled: true
  overwrite: true
  global:
    log:
      - '192.168.47.7:514 local0 warning'
    maxconn: 262144
    chroot:
      enable: true
      path: /var/lib/haproxy
    user: haproxy
    group: haproxy
    daemon: true
    stats:
      enable: true
      socketpath: /var/lib/haproxy/stats
      extra: user haproxy group haproxy
      mode: '0640'
      level: admin
    ssl-default-bind-ciphers: 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305'
    ssl-default-bind-options: 'no-sslv3 no-tlsv10 no-tlsv11 no-tls-tickets'
    extra:
      - ssl-dh-param-file /etc/haproxy/dhparam
      - tune.ssl.cachesize 100000
      - tune.ssl.maxrecord 2859
      - tune.ssl.lifetime 600
      - tune.ssl.default-dh-param 2048
      - tune.bufsize 32768
      - ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
      - ssl-default-server-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305
      - ssl-default-server-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
      - ssl-default-server-options no-sslv3 no-tlsv10 no-tlsv11 no-tls-tickets
      - nbproc 1
      - nbthread {{ grains['num_cpus'] }}

haproxy:
  defaults:
    log: global
    mode: http
    options:
      - log-health-checks
      - log-separate-errors
      - dontlognull
      - httplog
      - splice-auto
      - socket-stats
      - redispatch
    retries: 3
    maxconn: 131072
    timeouts:
      - connect 5s
      - client 30s
      - server 300s
      - http-keep-alive 30m
    errorfiles:
      503: /etc/haproxy/errorfiles/downtime.html.http
    extra:
      - compression algo gzip
      - compression type text/html text/plain text/css text/xml application/xhtml+xml image/svg+xml application/javascript application/json

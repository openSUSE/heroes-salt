haproxy:
  frontends:
    http:
      options:
        - http-server-close
      httprequests:
        - del-header:
          - X-Forwarded-For
          - ^X-Forwarded-(Proto|Ssl).*
          - ^HTTPS.*
        - add-header:
          - HTTPS on if is_ssl
          - X-Forwarded-Ssl on if is_ssl
          - X-Forwarded-Proto https if is_ssl
          - X-Forwarded-Protocol https if is_ssl
          - X-Forwarded-Proto http unless is_ssl
          - X-Forwarded-Protocol http unless is_ssl
      httpresponses:
        - del-header:
          - X-Powered-By
          - Server
        - set-header:
          - X-XSS-Protection "1; mode=block" if is_ssl
          - X-Content-Type-Options nosniff if is_ssl
          - Referrer-Policy no-referrer-when-downgrade if is_ssl
          - Strict-Transport-Security max-age=15768000
  backends:
    matrix-client:
      mode: http
      httprequests:
        - set-log-level silent
        - >-
          return status 200
          content-type application/json
          file /etc/haproxy/errorfiles/matrix-client.response
          hdr Server 'openSUSE is good for you'
          hdr Access-Control-Allow-Origin '*'
          hdr Cache no-cache
    matrix-federation:
      mode: http
      httprequests:
        - set-log-level silent
        - >-
          return status 200
          content-type application/json
          file /etc/haproxy/errorfiles/matrix-federation.response
          hdr Server 'openSUSE is good for you'
          hdr Access-Control-Allow-Origin '*'
          hdr Cache no-cache

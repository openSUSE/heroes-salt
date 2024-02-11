{%- from 'common/haproxy/map.jinja' import errorfiles %}

haproxy:
  backends:
    error_403:
      mode: http
      options:
        - tcpka
      httprequests: set-log-level silent
      extra:
        - errorfile 503 {{ errorfiles }}403.html.http
    security_txt:
      mode: http
      options:
        - tcpka
      httprequests: set-log-level silent
      extra:
        - errorfile 503 {{ errorfiles }}security.txt.http
    maintenance:
      extra:
        - errorfile 503 {{ errorfiles }}downtime.html.http

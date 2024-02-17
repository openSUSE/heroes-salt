{%- from 'common/haproxy/map.jinja' import errorfiles, options, server, httpcheck %}

haproxy:
  backends:
    conncheck:
      mode: http
      options: ['tcpka']
      httprequests: set-log-level silent
      extra:
        - errorfile 503 {{ errorfiles }}conncheck.txt.http
    mirrorcache:
      {{ options('httpchk') }}
      {{ httpcheck('mirrorcache-us.opensuse.org', 200) }}
      {{ server('mirrorcache-us', '192.168.67.12', 3000) }}
    static:
      {{ options('httpchk') }}
      {{ httpcheck('static.opensuse.org', 200, method='options') }}
      {{ server('narwal4', '192.168.67.5', 80) }}

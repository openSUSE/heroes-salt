apache:
  purge: True
  global:
    SetEnvIfs:
      - attribute: Request_URI
        regex: ^/check.txt$
        variables: donotlog
    CustomLog: /var/log/apache2/access_log
    LogFormat: combined env=!dontlog

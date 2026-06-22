profile:
  docker:
    daemon:
      log-level: warn
      log-driver: json-file
      log-opts:
        max-size: 10m
        max-file: '5'
      experimental: true
      ip6tables: true

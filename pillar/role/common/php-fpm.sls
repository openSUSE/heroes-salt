prometheus:
  wanted:
    component:
      - php-fpm_exporter
  pkg:
    component:
      php-fpm_exporter:
        name: prometheus-php-fpm_exporter
        service:
          name: prometheus-php-fpm_exporter

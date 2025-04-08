include:
  - role.common.php-fpm

prometheus:
  pkg:
    component:
      php-fpm-exporter:
        environ:
          args:
            phpfpm.scrape-uri: unix:///run/php-fpm/limesurvey.sock;/status
            phpfpm.fix-process-count: true

zypper:
  packages:
    limesurvey-config-apache: {}
    apache2-event: {}

include:
  - role.common.php-fpm

prometheus:
  pkg:
    component:
      php-fpm_exporter:
        environ:
          args:
            phpfpm.scrape-uri: unix:///run/php-fpm/limesurvey.sock;/status

zypper:
  packages:
    limesurvey-config-apache: {}
    apache2-event: {}

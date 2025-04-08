php-fpm_exporter-acl:
  acl.present:
    - name: /run/php-fpm
    - acl_type: default:user
    - acl_name: php-fpm_exporter
    - perms: rw

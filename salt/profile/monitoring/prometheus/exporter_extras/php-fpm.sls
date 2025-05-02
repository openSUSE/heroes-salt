php-fpm_exporter-acl:
  acl.present:
    - name: /run/php-fpm
    - acl_type: default:user
    - acl_name: php-fpm_exporter
    - perms: rw

php-fpm_exporter-acl_tmpfiles:
  file.managed:
    - name: /etc/tmpfiles.d/php-fpm-acl.conf
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - >-
            A /run/php-fpm - - - -
            d:m::rwx,o::--x,d:u:php-fpm_exporter:rw

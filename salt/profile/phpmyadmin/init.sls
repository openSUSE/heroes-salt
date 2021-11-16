phpmyadmin:
  pkg.installed:
    - pkgs:
      - apache2-mod_apparmor
      - apache2-prefork
      - phpMyAdmin

  service.running:
    - enable: True
    - name: apache2

/etc/apache2/vhosts.d/pmya.opensuse.org.conf:
  file.managed:
    - listen_in:
      - service: apache2
    - source: salt://profile/phpmyadmin/files/apache-vhost.conf

/etc/apache2/conf.d/phpMyAdmin.htpass:
  file.managed:
    - contents_pillar: profile:phpmyadmin:htpasswd

{% for key, value in pillar.profile.phpmyadmin.config.items() %}
{% if value != 'false' and value != 'true' %}
  {% set value = "'%s'" % value %}  # add quotes around non-boolean values
{% endif %}
phpmyadmin_config_{{ key }}:
  file.append:
    - name: /etc/phpMyAdmin/config.inc.php
    - text: $cfg['Servers'][$i]['{{ key }}'] = {{ value }};
{% endfor %}

# see profile/countdown/apache.sls for /etc/sysconfig/apache2

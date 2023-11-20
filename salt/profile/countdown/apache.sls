apache2:
  pkg.installed:
    - pkgs:
      - apache2-mod_apparmor
      - apache2-prefork
  service.running:
    - enable: True

/etc/apache2/vhosts.d/countdown.opensuse.org.conf:
  file.managed:
    - listen_in:
      - service: apache2
    - source: salt://profile/countdown/files/apache-vhost.conf
    - template: jinja

sysconfig_apache2_countdown:
  file.replace:
    - name: /etc/sysconfig/apache2
    - ignore_if_missing: {{ opts['test'] }}
    - pattern: ^APACHE_MODULES=.*$
    # original line:       "actions alias          auth_basic authn_file authz_host authz_groupfile authz_core authz_user autoindex cgi dir env expires include log_config mime negotiation setenvif ssl socache_shmcb userdir reqtimeout authn_core php7 rewrite"
    - repl: APACHE_MODULES="        alias apparmor auth_basic authn_file authz_host authz_groupfile authz_core authz_user autoindex     dir env expires include log_config mime negotiation setenvif     socache_shmcb         reqtimeout authn_core php7 rewrite remoteip status version"
    - listen_in:
      - service: apache2



# This is handled in /etc/logrotate.d/apache2 since Leap 15.x (same/duplicate entry there)
# removing the file on newer Leap versions to avoid  errors in logrotate (duplicate entry...)
/etc/logrotate.d/apache2-vhosts:
  file.absent

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
    - pattern: ^APACHE_MODULES=.*$
    # original line:       "actions alias          auth_basic authn_file authz_host authz_groupfile authz_core authz_user autoindex cgi dir env expires include log_config mime negotiation setenvif ssl socache_shmcb userdir reqtimeout authn_core php7 rewrite"
    - repl: APACHE_MODULES="        alias apparmor auth_basic authn_file authz_host authz_groupfile authz_core authz_user autoindex     dir env expires include log_config mime negotiation setenvif     socache_shmcb         reqtimeout authn_core      rewrite remoteip status"
    - listen_in:
      - service: apache2

/etc/logrotate.d/apache2-vhosts:
  file.managed:
    # same file as used for the wikis, no need to duplicate it
    - source: salt://profile/wiki/files/apache2-wiki.logrotate

# zypper-formula already uses/blocks the "apache2" name :-(
apache2_running:
  service.running:
    - enable: True
    - name: apache2

{% set mediawiki_1_27 = salt['pillar.get']('mediawiki_1_27:wikis', {}) %}
{% for wiki, data in mediawiki_1_27.items() %}

/etc/apache2/vhosts.d/{{ wiki }}.opensuse.org.conf:
  file.managed:
    - context:
      alias: {{ data.get('alias', '') }}
      wiki: {{ wiki }}
    - listen_in:
      - service: apache2
    - source: salt://profile/wiki/files/apache-vhost.conf
    - template: jinja

{% endfor %}

/etc/sysconfig/apache2:
  file.replace:
    - pattern: ^APACHE_MODULES=.*$
    # original line:       "actions alias          auth_basic authn_file authz_host authz_groupfile authz_core authz_user autoindex cgi dir env expires include log_config mime negotiation setenvif ssl socache_shmcb userdir reqtimeout authn_core php7 rewrite"
    - repl: APACHE_MODULES="        alias apparmor auth_basic authn_file authz_host authz_groupfile authz_core authz_user               dir env expires include log_config mime negotiation setenvif     socache_shmcb         reqtimeout authn_core php7 rewrite"
    - listen_in:
      - service: apache2

/etc/logrotate.d/apache2-wiki:
  file.managed:
    - source: salt://profile/wiki/files/apache2-wiki.logrotate

https://github.com/openSUSE/lists-o-o.git:
  git.latest:
    - branch: master
    - target: /var/lib/mailman/lists-o-o
    - rev: master
    - user: mailman

mailman_refresh:
  cmd.run:
    - names:
        - /usr/bin/mailman-web collectstatic
        - /usr/bin/mailman-web compress
    - shell: /bin/sh
    - onchanges:
        - git: https://github.com/openSUSE/lists-o-o.git
    - watch_in:
        - service: mailman_web_service

/var/lib/mailman/templates:
  file.symlink:
    - target: /var/lib/mailman/lists-o-o/mailman-templates
    - user: mailman
    - group: mailman

/srv/www/webapps/mailman/web/templates:
  file.symlink:
    - target: /var/lib/mailman/lists-o-o/webui-templates
    - user: mailmanweb
    - group: mailmanweb

/srv/www/webapps/mailman/web/static-openSUSE:
  file.symlink:
    - target: /var/lib/mailman/lists-o-o/webui-assets
    - user: mailmanweb
    - group: mailmanweb

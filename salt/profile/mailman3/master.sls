https://github.com/openSUSE/lists-o-o.git:
  git.latest:
    - branch: master
    - target: /var/lib/mailman/lists-o-o
    - rev: master
    - user: mailman

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

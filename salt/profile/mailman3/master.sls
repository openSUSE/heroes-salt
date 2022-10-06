lists-o-o_pgks:
  pkg.installed:
    - pkgs:
      - make
      - python3-libsass

https://github.com/openSUSE/lists-o-o.git:
  git.latest:
    - branch: master
    - target: /var/lib/mailman/lists-o-o
    - rev: master
    - user: mailman

/var/lib/mailman/templates:
  file.symlink:
    - target: /var/lib/mailman/lists-o-o/mailman-templates

/srv/www/webapps/mailman/web/templates:
  file.symlink:
    - target: /var/lib/mailman/lists-o-o/webui-templates

/srv/www/webapps/mailman/web/static-openSUSE:
  file.symlink:
    - target: /var/lib/mailman/lists-o-o/webui-assets

lists-o-o_build:
  cmd.run:
    - name: make
    - cwd: /var/lib/mailman/lists-o-o
    - runas: mailman

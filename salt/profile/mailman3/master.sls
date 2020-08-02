https://github.com/openSUSE/lists-o-o.git:
  git.latest:
    - branch: master
    - target: /var/lib/mailman/lists-o-o
    - rev: master
    - user: mailman

/var/lib/mailman/templates:
  file.symlink:
    - target: /var/lib/mailman/lists-o-o/mailman-templates

/var/lib/mailman_webui/templates:
  file.symlink:
    - target: /var/lib/mailman/lists-o-o/webui-templates

/var/lib/mailman_webui/static-openSUSE:
  file.symlink:
    - target: /var/lib/mailman/lists-o-o/webui-assets

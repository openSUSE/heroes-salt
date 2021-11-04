dehydrated:
  pkg.installed:
    - pkgs:
      - dehydrated

/etc/dehydrated/postrun-hooks.d/reloadhttpd.sh:
  file.managed:
    - mode: 755
    - contents: |
        #!/bin/sh
        if [ -e /usr/lib/systemd/system/apache2.service ] ; then
          systemctl reload apache2
        fi
        if [ -e /usr/lib/systemd/system/nginx.service ] ; then
          systemctl reload nginx
        fi

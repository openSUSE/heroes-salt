#!/bin/sh -eu
#{{ pillar['managed_by_salt'] }}

mariadb-admin --defaults-file=/etc/opt/promact/my.cnf --connect-timeout=10 \
  -h "$INSTANCE" -u monitor processlist > /srv/www/monitor-internal/promact-out/mysql_processlist_"$INSTANCE".txt

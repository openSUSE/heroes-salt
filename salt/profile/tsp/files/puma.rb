#!/usr/bin/env puma

application_path = '/srv/www/travel-support-program'
directory application_path
environment 'production'

daemonize false

stdout_redirect "/var/log/tsp/puma.stdout.log", "/var/log/tsp/puma.stderr.log"
bind "unix:///var/cache/tsp/puma.socket"

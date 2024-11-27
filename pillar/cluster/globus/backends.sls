{%- from 'common/haproxy/map.jinja' import options, server, httpcheck, rsync_backend_with_checks %}

haproxy:
  backends:
    mirror:
      {{ options('httpchk') }}
      {{ httpcheck('slc-mirror.opensuse.org', 200) }}
      {{ server('slc-mirror', '2a07:de40:617e:1905::a', 80) }}
    mirrorcache:
      {{ options('httpchk') }}
      {{ httpcheck('mirrorcache-us.opensuse.org', 200) }}
      {{ server('mirrorcache-us', '2a07:de40:617e:1906::a', 3000) }}
    static:
      {{ options('httpchk') }}
      {{ httpcheck('static.opensuse.org', 200, method='options') }}
      {#- TBD #}
      {{ server('narwal4', '::1', 80) }}
    mirror-rsync:
      {{ rsync_backend_with_checks('2a07:de40:617e:1905::a', extra='send-proxy') }}
    mirror-rsync-push:
      {{ rsync_backend_with_checks('2a07:de40:617e:1905::a', 874, extra='send-proxy') }}

{%- from 'common/haproxy/map.jinja' import options, server, httpcheck, rsync_backend_with_checks %}

haproxy:
  backends:
    debuginfod:
      {{ options('httpchk') }}
      {{ httpcheck('debuginfod.opensuse.org', 200, method='options') }}
      {{ server('debuginfod', '2a07:de40:617e:1907::a', 8002, extra_extra='inter 10s') }}
    # TODO: jekyll -> static -> SLC1 instead of proxying to PRG2
    jekyll:
      {{ options('httpchk') }}
      {{ httpcheck('universe.opensuse.org', 200, method='options') }}
      {{ server('jekyll', '2a07:de40:b27e:1203::e1', extra_extra='inter 1m') }}
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

{%- from 'common/haproxy/map.jinja' import narwals, options, server %}

haproxy:
  backends:
    www_openid_ldap:
      {{ options() }}
      {{ server('ldap-proxy', '192.168.47.3') }}
      mode: http
    staticpages:
      {{ options('httpchk OPTIONS / HTTP/1.1\r\nHost:\ static.opensuse.org') }}
      balance: roundrobin
      mode: http
      servers:
        {%- for static_server, address in narwals.items() %}
        {{ server(static_server, address, 80, header=False) }}
        {%- endfor %}
    jekyll:
      {{ options('httpchk OPTIONS / HTTP/1.1\r\nHOST:\ search.opensuse.org') }}
      {{ server('jekyll', '2a07:de40:b27e:1203::e1') }}
      acls:
        - is_jekyll_test          hdr_reg(host) -i (.*)-test\.opensuse\.org
      extra: http-request replace-header HOST (.*)-test(.*) \1\2 if is_jekyll_test
    limesurvey:
      {{ options() }}
      {{ server('limesurvey', '2a07:de40:b27e:1203::b4', extra_extra='inter 5000') }}

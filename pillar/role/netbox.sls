apache:
  sites:
    netbox:
      interface: '{{ grains['fqdn_ip6'][0] }}'
      port: 443
      ServerName: netbox1.infra.opensuse.org
      Header: always set Strict-Transport-Security "max-age=63072000"
      Protocols: h2 http/1.1
      SSLCertificateFile: /etc/ssl/services/netbox1.infra.opensuse.org/fullchain.pem
      SSLCertificateKeyFile: /etc/ssl/services/netbox1.infra.opensuse.org/privkey.pem
      SSLHonorCipherOrder: false
      SSLProtocol: all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1 -TLSv1.2
      SSLSessionTickets: false
      SSLStaplingCache: '"shmcb:logs/ssl_stapling(32768)"'
      SSLUseStapling: true
      Alias:
        /static: /usr/share/netbox/netbox/static
      Directory:
        /usr/share/netbox/netbox/static:
          Options: >-
            Indexes
            FollowSymLinks
            MultiViews
          AllowOverride: None
          Require: all granted
      RequestHeader: set "X-Forwarded-Proto" expr=%{REQUEST_SCHEME}
      ProxyRoute:
        - ProxyPassSource: /static
          ProxyPassTarget: '!'
        - ProxyPassSource: /
          ProxyPassTarget: unix:/run/netbox/gunicorn/socket

{%- from 'macros.jinja' import redis %}
{{ redis('netbox') }}

zypper:
  packages:
    netbox: {}
  repositories:
    openSUSE:infrastructure:netbox:
      baseurl: http://download.infra.opensuse.org/repositories/openSUSE:/infrastructure:/netbox/$releasever/
      priority: 98
      refresh: true

include:
  - role.common.apache

apache_httpd:
  modules:
    - proxy
    - proxy_http
  vhosts:
    netbox:
      listen: '{{ grains['fqdn_ip6'][0] }}:443'
      CustomLog:
        env: =!donotlog
      ServerName: netbox1.infra.opensuse.org
      Header: always set Strict-Transport-Security "max-age=63072000"
      Protocols:
        - h2
        - http/1.1
      SSLCertificateFile: /etc/ssl/services/netbox1.infra.opensuse.org/fullchain.pem
      SSLCertificateKeyFile: /etc/ssl/services/netbox1.infra.opensuse.org/privkey.pem
      SSLHonorCipherOrder: false
      SSLProtocol: all -SSLv2 -SSLv3 -TLSv1 -TLSv1.1 -TLSv1.2
      Alias:
        /static: /usr/share/netbox/static
        /static/docs: /usr/share/doc/packages/netbox/docs
      Directory:
        /usr/share/netbox/static:
          Require: all granted
        /usr/share/doc/packages/netbox/docs:
          Require: all granted
      RequestHeader: set "X-Forwarded-Proto" expr=%{REQUEST_SCHEME}
      RewriteEngine: true
      RewriteRule:
        ^/login/$: /oauth/login/oidc/ [R]
      ProxyPass:
        /static: '!'
        /: unix:/run/netbox/gunicorn/socket|http://localhost/

groups:
  redis:
    system: true
    members:
      - _netbox

{%- from 'macros.jinja' import redis %}
{{ redis('netbox', databases=2) }}

zypper:
  packages:
    netbox: {}
  repositories:
    devel:languages:python:backports:
      baseurl: https://$mirror_ext/repositories/devel:/languages:/python:/backports/$releasever/
      priority: 100
      refresh: true
    openSUSE:infrastructure:netbox:
      baseurl: http://$mirror_int/repositories/openSUSE:/infrastructure:/netbox/$releasever/
      priority: 98
      refresh: true

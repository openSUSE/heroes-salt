{%- if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.sample-webapp
{%- endif %}

profile:
  sample-webapp:
    config:
      AssetDir: /usr/share/sample-go-webapp/web/assets
      BaseUrl: https://sample-app-dev.infra.opensuse.org
      Bind: '[::]:8080'
      ClientId: sample-app
      OidcBaseUrl: https://idm-ext-dev.infra.opensuse.org/oauth2/openid/sample-app

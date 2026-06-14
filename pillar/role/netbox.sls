include:
  - role.docker
  {%- if salt['grains.get']('include_secrets', True) %}
  - secrets.role.netbox
  {%- endif %}


profile:
  docker:
    daemon:
      ipv6: true
      fixed-cidr-v6: 2a07:de40:b27e:400{{ grains['host'][-1] }}::/64
  # most configuration is static in salt/profile/netbox/files/netbox.env.jinja
  netbox:
    hostname:
      frontend: netbox.infra.opensuse.org
    db:
      host: postgresql.infra.opensuse.org
      name: netbox
      username: netbox
    versiontag: v4.5.10-suse
    oidc:
      endpoint: https://idm.infra.opensuse.org/oauth2/openid/netbox
      key: netbox

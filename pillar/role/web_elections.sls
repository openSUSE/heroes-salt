include:
  - role.common.nginx
  {% if salt['grains.get']('include_secrets', True) %}
  - secrets.role.web_elections
  {% endif %}

nginx:
  ng:
    servers:
      managed:
        elections.opensuse.org.conf:
          config:
            - upstream helios:
              - server:
                  - unix:/srv/www/vhosts/helios-server/tmp/sockets/helios.sock
                  - fail_timeout=0
            - server:
              - listen: 80
              - location /:
                - include: /etc/nginx/uwsgi_params
                - uwsgi_pass: helios
              - server_name: elections.opensuse.org
              - try_files: $uri/index.html $uri.html $uri @helios
              - access_log: /var/log/nginx/elections.access.log combined
              - error_log: /var/log/nginx/elections.error.log
          enabled: True

# postgres:users:helios:password included from pillar/secrets/role/web_elections.sls

profile:
  helios:
    allowed_hosts:
      - elections.opensuse.org
      - localhost
    database_host: postgresql.infra.opensuse.org
    database_name: helios
    database_user: helios
    default_from_email: election-officials@opensuse.org
    default_from_name: openSUSE Election Officials
    election_creators:
      # admins
      - cboltz
      - tampakrap
      # election commitee 2018
      - terrorpup
      - warlordfff
    email_host: relay.infra.opensuse.org
    help_email_address: election-officials@opensuse.org
    # secret_key included from pillar/secrets/role/web_elections.sls
    url_host: https://elections.opensuse.org

zypper:
  repositories:
    openSUSE:infrastructure:elections.opensuse.org:
      baseurl: http://download.infra.opensuse.org/repositories/openSUSE:/infrastructure:/elections.opensuse.org/openSUSE_Leap_{{ salt['grains.get']('osrelease') }}/
      priority: 100
      refresh: True

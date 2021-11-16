{% if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.phpmyadmin
{% endif %}

# apparmor: see salt/profile/countdown for the Apache AppArmor profile, it includes a ^vhost_phpmyadmin hat

profile:
  phpmyadmin:
    config:
      host: 192.168.47.4
      port: 3307
      AllowRoot: 'false'
      only_db: members
  # htpasswd: included from pillar/secrets/role/phpmyadmin.sls

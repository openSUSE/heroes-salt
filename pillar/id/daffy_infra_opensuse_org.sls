grains:
  city: nuremberg
  country: de
  roles:
    - login
  salt_cluster: opensuse
  virt_cluster: atreju

{% set osrelease = salt['grains.get']('osrelease') %}
{% if osrelease == '42.3' %}
monitoring:
  check_zypper:
    whitelist:
    - apache2-mod_auth_memcookie
{% endif %}

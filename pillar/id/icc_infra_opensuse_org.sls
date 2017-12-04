grains:
  city: nuremberg
  country: de
  salt_cluster: opensuse
  virt_cluster: atreju

{% set osrelease = salt['grains.get']('osrelease') %}
{% if osrelease == '11.4' %}
profile:
  monitoring:
    check_zypper:
      whitelist:
        - mongodb
{% endif %}

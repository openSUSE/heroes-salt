grains:
  city: nuremberg
  country: de
  salt_cluster: opensuse
  virt_cluster: atreju

{% set osrelease = salt['grains.get']('osrelease') %}
{% if osrelease == '42.3' %}
profile:
  monitoring:
    check_zypper:
      whitelist:
      - chrony
{% endif %}

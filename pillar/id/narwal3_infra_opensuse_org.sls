grains:
  city: nuremberg
  country: de
  salt_cluster: opensuse
  virt_cluster: atreju

{% set osrelease = salt['grains.get']('osrelease') %}
{% if osrelease == '12.3' %}
monitoring:
  check_zypper:
    whitelist:
      - ca-certificates-suse
{% endif %}

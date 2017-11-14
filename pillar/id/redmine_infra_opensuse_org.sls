grains:
  city: nuremberg
  country: de
  salt_cluster: opensuse
  virt_cluster: atreju

{% set osrelease = salt['grains.get']('osrelease') %}
{% if osrelease == '11.4' %}
monitoring:
  check_zypper:
    whitelist:
      - libpgm-5_2-0
      - libsodium13
      - libsodium18
      - libyaml-0-2
      - libzmq5
      - python-Jinja2
      - python-MarkupSafe
      - python-PyYAML
      - python-apache-libcloud
      - python-backports.ssl_match_hostname
      - python-backports_abc
      - python-certifi
      - python-futures
      - python-msgpack-python
      - python-psutil
      - python-pycrypto
      - python-pyzmq
      - python-simplejson
      - python-singledispatch
      - python-six
      - python-tornado
{% endif %}

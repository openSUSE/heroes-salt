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
      - libev4
      - libpgm-5_2-0
      - libsodium13
      - libsodium18
      - libsqlite3-0
      - libyaml-0-2
      - libzmq5
      - mongodb
      - python-Jinja2
      - python-MarkupSafe
      - python-PyYAML
      - python-apache-libcloud
      - python-backports.ssl_match_hostname
      - python-backports_abc
      - python-certifi
      - python-cffi
      - python-ecdsa
      - python-futures
      - python-gevent
      - python-greenlet
      - python-msgpack-python
      - python-paramiko
      - python-psutil
      - python-py
      - python-pycparser
      - python-pycrypto
      - python-pyzmq
      - python-simplejson
      - python-singledispatch
      - python-six
      - python-tornado
      - sqlite3
      - zeromq-tools
{% endif %}

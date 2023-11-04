include:
  - .common.powerdns
  {%- if salt['grains.get']('include_secrets', True) %}
  - secrets.role.nameserver.primary
  - secrets.id.{{ grains['id'] }}
  {%- endif %}

{%- load_yaml as data %}
axfr:
  - 127.0.0.0/8
  - ::1
  - 192.168.47.60/32
  - 192.168.47.63/32
  - 192.168.47.101/32
  - 192.168.47.102/32
  - 192.168.253.186/32
  - 192.168.252.186/32
  - 192.168.67.1/32
  - 192.168.67.2/32
  - 192.168.67.3/32
  - 192.168.67.4/32
  - 192.168.87.1/32
  - 192.168.87.5/32
  - 192.168.251.4/32
  - 172.16.130.21/32
  - 172.16.130.22/32
also_notify:
  - 192.168.47.60
  - 192.168.47.63
  - 192.168.47.10
  - 192.168.47.102
  - 192.168.252.186
  - 192.168.253.186
  - 192.168.67.1
  - 192.168.67.2
  - 192.168.67.3
  - 192.168.67.4
  - 192.168.87.1
  - 192.168.87.5
  - 192.168.251.4
  - 172.16.130.21
  - 172.16.130.22
only_notify:
  - 192.168.47.60/32
  - 192.168.47.63/32
  - 192.168.47.101/32
  - 192.168.47.102/32
  - 192.168.252.186/32
  - 192.168.253.186/32
  - 192.168.67.4/32
  - 192.168.87.1/32
  - 192.168.87.5/32
  - 172.16.130.21/32
  - 172.16.130.22/32
{%- endload %}

powerdns:
  config:
    # secrets are in pillar/secrets/{id,role}/
    allow-axfr-ips: {{ ','.join(data.axfr) }}
    also-notify: {{ ','.join(data.also_notify) }}
    only-notify: {{ ','.join(data.only_notify) }}
    default-soa-edit: INCEPTION-INCREMENT
    default-soa-edit-signed: INCEPTION-EPOCH
    master: 'yes'
    setgid: pdns
    setuid: pdns
    launch: 'gmysql'
    gmysql-socket: /run/mysql/mysql.sock
    gmysql-dbname: pdns
    gmysql-dnssec: yes
    slave-renotify: 'yes'
    api: 'yes'

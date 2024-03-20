include:
  - .common.powerdns
  {%- if salt['grains.get']('include_secrets', True) %}
  - secrets.role.nameserver.primary
  - secrets.id.{{ grains['id'].replace('.', '_') }}
  {%- endif %}

{%- load_yaml as data %}
also_notify:
  - 2a07:de40:b27e:64::c0a8:4304  # provo-ns
  - 2a07:de40:b27e:64::c0a8:5701  # stonehat
  - 2a07:de40:b27e:64::c0a8:5705  # ipx-proxy1
  - 2a07:de40:b27e:1204::21       # prg-ns1
  - 2a07:de40:b27e:1204::22       # prg-ns2
  - 2a07:de40:b27e:5002:c707:5ca1:19e:ce5e  # ipx-ns1 / qsc-ns3
only_notify:
  - 2a07:de40:b27e:64::c0a8:4304/128
  - 2a07:de40:b27e:64::c0a8:5701/128
  - 2a07:de40:b27e:64::c0a8:5705/128
  - 2a07:de40:b27e:1204::21/128
  - 2a07:de40:b27e:1204::22/128
  - 2a07:de40:b27e:5002:c707:5ca1:19e:ce5e/128
allow_axfr:
  - 2a07:de40:b27e:64::c0a8:4304/128
  - 2a07:de40:b27e:64::c0a8:5701/128  # stonehat
  - 2a07:de40:b27e:64::c0a8:5705/128
  - 2a07:de40:b27e:1204::21/128
  - 2a07:de40:b27e:1204::22/128
  - 2a07:de40:b27e:5002:c707:5ca1:19e:ce5e/128
  - 2a07:de40:b27e:64::ac10:c906/128  # stonehat p2p
{%- endload %}

powerdns:
  config:
    # secrets are in pillar/secrets/{id,role}/
    allow-axfr-ips: {{ ','.join(data.allow_axfr) }}
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

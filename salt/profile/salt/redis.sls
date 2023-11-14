{%- set salt_pillar = pillar.get('salt', {}) -%}
{%- set master_pillar = salt_pillar.get('master', {}) -%}
{%- set redis_config = '/etc/redis/salt.conf' -%}
{%- set redis_service = 'redis@salt' -%}

include:
  - salt.master

salt_redis_packages:
  pkg.installed:
    - pkgs:
      - python3-redis
      - redis7
    - watch_in:
      - service: salt-master

{#- to-do: move Redis configuration to a formula #}
{{ redis_config }}:
  file.managed:
    - contents:
      - port 0
      - tcp-backlog 511
      - unixsocket /run/redis/salt.sock
      - unixsocketperm 460
      - timeout 0
      - supervised systemd
      - pidfile /run/redis/salt.pid
      - logfile /var/log/redis/salt.log
      - databases 1
      - dir /var/lib/redis/salt/
      - acllog-max-len 64
      - requirepass {{ master_pillar['cache.redis.password'] }}
    - user: root
    - group: redis
    - mode: '0640'
    - require:
      - pkg: salt_redis_packages

/var/lib/redis/salt:
  file.directory:
    - user: redis
    - group: redis
    - mode: '0750'
    - require:
      - pkg: salt_redis_packages

salt_redis_service:
  service.running:
    - name: {{ redis_service }}
    - enable: true
    - require:
      - pkg: salt_redis_packages
    - watch:
      - file: {{ redis_config }}

salt_redis_membership:
  group.present:
    - name: redis
    - require:
      - pkg: salt_redis_packages
    - addusers:
      - {{ master_pillar['user'] }}

{%- set fqdn    = grains['fqdn']        -%}
{%- set address = grains['fqdn_ip6'][0] -%}

{%- set ssldir  = '/etc/ssl/services/' ~ fqdn ~ '/' -%}
{%- set crt     =  ssldir ~ 'fullchain.pem'         -%}
{%- set key     =  ssldir ~ 'privkey.pem'           -%}

{%- import_yaml 'FORMULAS.yaml' as formulas_yaml -%}
include:
  - infra.nodegroups
{% if salt['grains.get']('include_secrets', True) %}
  - secrets.role.saltmaster
{% endif %}

salt:
  master_remove_config: True
  master:
    auth.ldap.accountattributename: spn
    auth.ldap.basedn: o=heroes
    auth.ldap.binddn: uid=salt,o=heroes
    auth.ldap.filter:
      {%- raw %}
      '(&(spn={{ username }})(objectClass=person)(memberOf=spn=idm_all_persons@infra.opensuse.org,o=heroes))'
      {%- endraw %}
    auth.ldap.groupattribute: memberof
    auth.ldap.groupclass: account
    auth.ldap.groupou: null
    auth.ldap.port: 636
    auth.ldap.scope: 1
    auth.ldap.server: ldap.infra.opensuse.org
    auth.ldap.tls: True
    cache: redis
    cache.redis.unix_socket_path: /run/redis/salt.sock
    cli_summary: True
    default_top: production
    ext_pillar_first: True
    external_auth:
      ldap:
        wheel@infra.opensuse.org%:
          - .*
          - '@jobs'
          - '@runner'
          - '@wheel'
    fileserver_backend:
      - git
      - roots
    file_roots:
      # consider changing back to __env__ after a solution for https://github.com/saltstack/salt/issues/62967
      production:
        - /srv/salt
        - /usr/share/salt-formulas/states
        - /srv/formula
    gather_job_timeout: 10
    ipc_write_buffer: dynamic
    timeout: 15
    gitfs_ssl_verify: True
    hash_type: sha512
    {%- if grains.get('country') == 'cz' %}
    {#- _needs_ to align with the "ipv6" setting in pillar.common! #}
    interface: '::'
    {%- endif %}
    key_cache: sched
    ping_on_rotate: True
    pillar_cache: True
    pillar_cache_backend: memory
    pillar_cache_ttl: 1800
    pillar_gitfs_ssl_verify: True
    pillar_merge_lists: True
    pillar_roots:
      __env__:
        - /srv/pillar
    pillar_source_merging_strategy: smart
    rest_cherrypy:
      host: {{ address }}
      port: 4550
      ssl_crt: {{ crt }}
      ssl_key: {{ key }}
    sock_pool_size: 30
    state_aggregate: True
    state_compress_ids: True
    state_output: changes
    state_verbose: False
    top_file_merging_strategy: same
    user: salt
    worker_threads: {{ grains['num_cpus'] }}
    zmq_backlog: 10000
    pub_hwm: 10000

infrastructure:
  salt:
    formulas:
      {%- for formula in formulas_yaml['package'] %}
      - {{ formula }}-formula
      {%- endfor %}

profile:
  salt:
    formulas:
      git:
        {%- for formula, config in formulas_yaml['git'].items() %}
        {{ formula }}: {{ config }}
        {%- endfor %}
    saline:
      restapi:
        host: {{ address }}
        ssl_crt: {{ crt }}
        ssl_key: {{ key }}
        log_access_file: /var/log/salt/saline-api-access.log
        log_error_file: /var/log/salt/saline-api-error.log

redis:
  salt:
    acllog-max-len: 64
    databases: 1
    port: 0
    tcp-backlog: 511
    timeout: 0

rsync:
  modules:
    salt-push:
      path: /srv/salt-git/
      comment: /srv/salt-git/
      list: 'false'
      uid: root
      gid: salt
      auth users: saltpush
      read only: false
      hosts allow:
        {%- if grains.get('country') == 'cz' %}
        - 2a07:de40:b27e:1203::126 # gitlab-runner1
        - 2a07:de40:b27e:1203::127 # gitlab-runner2
        {%- else %}
        - 172.16.164.126
        - 172.16.164.127
        {%- endif %}

users:
  redis:
    members:
      - salt

zypper:
  packages:
    python3-ldap: {}
    python3-redis: {}
    saline: {}

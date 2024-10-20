{%- import_yaml 'id/' ~ grains['id'].replace('.', '_') ~ '.sls' as idstruct -%}
{%- set roles = idstruct.get('roles', []) -%}

sudoers:
  defaults:
    generic:
      - always_set_home
      - secure_path="/usr/sbin:/usr/bin:/sbin:/bin"
      - env_reset
      - >-
        env_keep=
        "LANG LC_ADDRESS LC_CTYPE LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES LC_MONETARY
        LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE LC_TIME LC_ALL LANGUAGE LINGUAS XDG_SESSION_COOKIE"
      - '!insults'
  groups:
    wheel:
      - 'ALL=(ALL) ALL'
    {%- for role in roles %}
    {%- set role = role.replace('web_', '') %}
    {{ role }}-admins:
      - '{{ grains['host'] }}=(ALL) ALL'
    {%- endfor %}
  users:
    root:
      - 'ALL=(ALL) ALL'
    monitor:
      - 'ALL = (root) NOPASSWD: /usr/bin/zypper --quiet pa --orphaned'
      - 'ALL = (root) NOPASSWD: /usr/sbin/rpmconfigcheck'
  purge_includedir: true

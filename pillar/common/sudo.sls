{%- import_yaml 'id/' ~ grains['id'].replace('.', '_') ~ '.sls' as idstruct -%}
{%- set roles = idstruct.get('roles', []) -%}

sudoers:
  defaults:
    generic:
      - always_set_home
      - secure_path="/usr/sbin:/usr/bin:/sbin:/bin"
      - env_reset
      - env_keep="LANG LC_ADDRESS LC_CTYPE LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE LC_TIME LC_ALL LANGUAGE LINGUAS XDG_SESSION_COOKIE"
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
    nagios:
      - 'ALL=(ALL) NOPASSWD: /usr/sbin/zypp-refresh,/usr/bin/zypper ref,/usr/bin/zypper sl,/usr/bin/zypper --xmlout --non-interactive list-updates -t package -t patch'
      {%- if grains['virtual'] == 'physical' %}
      - 'ALL=(ALL) NOPASSWD: /usr/lib/nagios/plugins/check_md_raid, /sbin/multipath, /usr/bin/ipmitool'
      {%- endif %}
  purge_includedir: true

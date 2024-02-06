postfix:
  pkg.installed: []
  service.running:
    - enable: True

# update /etc/aliases
{%- for user, target in salt['pillar.get']('profile:postfix:aliases', {}).items() %}
postfix_alias_present_{{ user }}:
  alias.present:
    - name: {{ user }}
    - target: {{ target }}
{%- endfor %}

# update main.cf
# (only update options given in profile:postfix:maincf pillar, other settings stay unchanged)
{%- for option, value in salt['pillar.get']('profile:postfix:maincf', {}).items() %}
/etc/postfix/main.cf_{{ option }}:
  file.replace:
    - name: /etc/postfix/main.cf
    - ignore_if_missing: {{ opts['test'] }}
    - pattern: '^{{ option }} *=.*$'
    - repl: '{{ option }} = {{ value }}'
    - append_if_not_found: True
    - ignore_if_missing: {{ opts['test'] }}
    - require:
      - pkg: postfix
    - watch_in:
      - service: postfix
{%- endfor %}

# update master.cf
# (only update options given in profile:postfix:maincf pillar, other settings stay unchanged)
{%- for option, value in salt['pillar.get']('profile:postfix:mastercf', {}).items() %}
/etc/postfix/master.cf_{{ option }}:
  file.replace:
    - name: /etc/postfix/master.cf
    - ignore_if_missing: {{ opts['test'] }}
    - pattern: '^{{ option }}\s.*$'
    - repl: '{{ option }} {{ value }}'
    - append_if_not_found: True
    - require:
      - pkg: postfix
    - watch_in:
      - service: postfix
{%- endfor %}

{%- if 'discard_ndrs' in salt['pillar.get']('profile:postfix:maincf:smtpd_sender_restrictions') %}
/etc/postfix/discard_ndrs:
  file.managed:
    - contents:
        - {{ pillar['managed_by_salt'] | yaml_encode }}
        - <> discard
    - require:
      - pkg: postfix
  cmd.run:
    - name: postmap /etc/postfix/discard_ndrs
    - onchanges:
      - file: /etc/postfix/discard_ndrs
{%- endif %}

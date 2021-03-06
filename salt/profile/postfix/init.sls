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
    - pattern: '^{{ option }} *=.*$'
    - repl: '{{ option }} = {{ value }}'
    - append_if_not_found: True
    - require:
      - pkg: postfix
    - watch_in:
      - service: postfix
{%- endfor %}

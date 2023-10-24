{%- set apparmor_local_dir = "/etc/apparmor.d/local/" %}
{%- set overrides_sections = [] %}
{%- if 'apparmor' in pillar %}
{%-   if 'local' in pillar.apparmor %}
{%-     for profile_name, profile_data in pillar.apparmor.local.items() %}
{%-       set overrides_filename = apparmor_local_dir  ~ profile_name %}
{%-       set overrides_section  = 'apparmor_local_' ~ profile_name.replace('.', '_') %}
{%-       do overrides_sections.append(overrides_section) %}
{{ overrides_section }}:
  file.managed:
    - name: {{ overrides_filename }}
    - makedirs: true
    - dir_mode: '0755'
    - mode: '0644'
    - user: root
    - group: root
    - watch_in:
    - contents:
      {%- if 'managed_by_salt' in pillar %}
      - "# {{ pillar.managed_by_salt }}"
      {%- endif %}
      - "# Site-specific additions and overrides for '{{ profile_name }}'."
      - "# For more details, please see /etc/apparmor.d/local/README."
      {%- for override in profile_data %}
      - {{ override }}
      {%- endfor %}
{%-     endfor %}

apparmor_reload:
  cmd.run:
    - name: '/usr/bin/aa-enabled && /usr/bin/systemctl try-reload-or-restart apparmor'
    - onchanges:
      {%- for overrides_section in overrides_sections %}
      - {{ overrides_section }}
      {%- endfor %}
{%-   endif %}
{%- endif %}

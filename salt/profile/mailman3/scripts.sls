mailman_scripts:
  file.managed:
    - names:
        {%- for script in [
              'unsubscribe_member_from_all_lists',
            ]
        %}
        - /usr/local/bin/mailman-{{ script }}:
            - source: salt://profile/mailman3/files/scripts/{{ script }}.py.jinja
        {%- endfor %}
    - mode: '0755'
    - group: mailman
    - template: jinja

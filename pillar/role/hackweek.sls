sudoers:
  users:
    hackweek:
      {%- for service in [
                'hackweek',
                'hackweek-sphinx',
              ]
      %}
        {%- for command in [
                  'restart',
                  'start',
                  'status',
                  'stop',
                ]
        %}
      - 'dale=(root) NOPASSWD: /usr/bin/systemctl {{ command }} {{ service }}'
        {%- endfor %}
      {%- endfor %}

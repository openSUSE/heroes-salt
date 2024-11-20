sudoers:
  users:
    osem:
      {%- for service in [
                'osem',
                'osem-dj',
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

zypper:
  repositories:
    devel:languages:ruby:
      baseurl: https://$mirror_int/repositories/devel:/languages:/ruby/$releasever/
      priority: 100
      refresh: True

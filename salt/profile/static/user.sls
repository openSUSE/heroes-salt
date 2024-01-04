{% set roles = salt['pillar.get']('roles', []) %}

web_static:
    user.present:
    - createhome: False
    - home: /home/web_static
    - shell: /bin/bash

/home/web_static:
  file.directory:
    - user: root

/home/web_static/.ssh:
  file.directory:
    - user: root

{% if 'web_static' in roles %}
/home/web_static/.ssh/authorized_keys:
  file.managed:
    - contents_pillar: profile:web_static:ssh_pubkey
    - mode: 644
    - user: root
{% endif %}

{% set roles = salt['grains.get']('roles', []) %}

web_jekyll:
    user.present:
    - createhome: False
    - home: /home/web_jekyll
    - shell: /bin/bash

/home/web_jekyll:
  file.directory:
    - user: root

/home/web_jekyll/.ssh:
  file.directory:
    - user: root

{% if 'web_jekyll' in roles %}
/home/web_jekyll/.ssh/authorized_keys:
  file.managed:
    - contents_pillar: profile:web_jekyll:ssh_pubkey
    - mode: 644
    - user: root
{% endif %}

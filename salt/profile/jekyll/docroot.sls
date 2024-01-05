{% set websites = salt['pillar.get']('profile:web_jekyll:websites') %}

jekyll_vhosts_dir:
  file.directory:
    - name: /srv/www/vhosts/

{% for website in websites %}
jekyll_vhosts_dir_{{ website }}:
  file.directory:
    - name: /srv/www/vhosts/{{ website }}.opensuse.org
    - user: web_jekyll
{% endfor %}

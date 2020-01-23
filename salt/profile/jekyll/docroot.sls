{% set websites = salt['pillar.get']('profile:web_jekyll:websites') %}

jekyll_vhosts_dir:
  file.directory:
    - name: /srv/www/vhosts/

{% for website in websites %}
/srv/www/vhosts/{{ website }}.opensuse.org:
  file.directory:
    - user: web_jekyll
{% endfor %}

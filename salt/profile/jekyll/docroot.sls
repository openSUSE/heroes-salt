{% set websites = salt['pillar.get']('profile:web_jekyll:websites') %}

/srv/www/vhosts/:
  file.directory

{% for website in websites %}
/srv/www/vhosts/{{ website }}.opensuse.org:
  file.directory:
    - user: web_jekyll
{% endfor %}

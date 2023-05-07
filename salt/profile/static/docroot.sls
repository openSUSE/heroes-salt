{% set websites = salt['pillar.get']('profile:web_static:websites') %}
{% set exclusions = ['oom'] %}

/srv/www/vhosts/:
  file.directory

{% for website in websites %}
{%- if not website in exclusions %}
/srv/www/vhosts/{{ website }}.opensuse.org:
  file.directory:
    - user: web_static
{%- endif %}
{% endfor %}

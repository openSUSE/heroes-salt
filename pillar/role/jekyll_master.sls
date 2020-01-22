{% if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.static_master
{% endif %}

profile:
  web_jekyll:
    git_repos:
      news.opensuse.org:
        repo: https://github.com/openSUSE/news-o-o.git
      planet.opensuse.org:
        repo: https://github.com/hellcp/planet-o-o.git

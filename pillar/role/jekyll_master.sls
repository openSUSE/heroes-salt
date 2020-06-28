{% if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.jekyll_master
{% endif %}

profile:
  web_jekyll:
    git_repos:
      news.opensuse.org:
        repo: https://github.com/openSUSE/news-o-o.git
      planet.opensuse.org:
        repo: https://github.com/openSUSE/planet-o-o.git
      search.opensuse.org:
        repo: https://github.com/openSUSE/search-o-o.git
      www.opensuse.org:
        repo: https://github.com/openSUSE/www.opensuse.org.git
      yast.opensuse.org:
        repo: https://github.com/yast/yast.github.io.git
    server_list:
      - jekyll.infra.opensuse.org
    ssh_known_hosts: |
        192.168.47.61,jekyll.infra.opensuse.org ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDIQrbRoDfhX4IYr5qALDKfslpvvJ8SJRLBqkUiHifEq05SMbsqWxoylIYrQRvHw5v0jl3UNWgISWRZ1AtBDVVQ=

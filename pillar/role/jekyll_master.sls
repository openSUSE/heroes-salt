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
      101.opensuse.org:
        repo: https://github.com/openSUSE/mentoring.git
        branch: main
      monitor.opensuse.org:
        repo: https://github.com/openSUSE/monitor-o-o.git
      debuginfod.opensuse.org:
        repo: https://github.com/openSUSE/debuginfod-o-o.git
      get.opensuse.org:
        repo: https://github.com/openSUSE/get-o-o.git
        branch: main
    server_list:
      - jekyll.infra.opensuse.org
    ssh_known_hosts: |
        192.168.47.61,jekyll.infra.opensuse.org ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDIQrbRoDfhX4IYr5qALDKfslpvvJ8SJRLBqkUiHifEq05SMbsqWxoylIYrQRvHw5v0jl3UNWgISWRZ1AtBDVVQ=

zypper:
  repositories:
    openSUSE:infrastructure:jekyll:
      baseurl: http://download.infra.opensuse.org/repositories/openSUSE:/infrastructure:/jekyll/$releasever/
      priority: 100
      refresh: True
    devel:languages:ruby:
      baseurl: http://download.infra.opensuse.org/repositories/devel:/languages:/ruby/$releasever/
      priority: 100
      refresh: True

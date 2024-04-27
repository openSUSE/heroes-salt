{% if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.jekyll_master
{% endif %}

{%- set osrelease = salt['grains.get']('osrelease') %}

profile:
  {%- if osrelease == '15.5' %}
  monitoring:
    check_zypper:
      whitelist:
        - libruby3_1-3_1
        - ruby3.1
        - ruby3.1-devel
  {%- endif %}

  web_jekyll:
    git_repos:
      news.opensuse.org:
        repo: https://github.com/openSUSE/news-o-o.git
      planet.opensuse.org:
        repo: https://github.com/openSUSE/planet-o-o.git
      search.opensuse.org:
        repo: https://github.com/openSUSE/search-o-o.git
      www.opensuse.org:
        branch: main
        repo: https://github.com/openSUSE/www-o-o.git
      yast.opensuse.org:
        repo: https://github.com/yast/yast.github.io.git
      101.opensuse.org:
        repo: https://github.com/openSUSE/mentoring.git
        branch: main
      security.opensuse.org:
        repo: https://github.com/openSUSE/security-team-blog.git
        branch: main
      monitor.opensuse.org:
        repo: https://github.com/openSUSE/monitor-o-o.git
      get.opensuse.org:
        repo: https://github.com/openSUSE/get-o-o.git
        branch: main
      universe.opensuse.org:
        repo: https://github.com/openSUSE/universe-o-o.git
        branch: main
    server_list:
      - jekyll.infra.opensuse.org

zypper:
  repositories:
    openSUSE:infrastructure:jekyll:
      baseurl: http://download-prg.infra.opensuse.org/repositories/openSUSE:/infrastructure:/jekyll/$releasever/
      priority: 100
      refresh: True
    devel:languages:ruby:
      baseurl: https://downloadcontent.opensuse.org/repositories/devel:/languages:/ruby/$releasever/
      priority: 100
      refresh: True

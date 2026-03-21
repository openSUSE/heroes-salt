{% if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.jekyll_master
{% endif %}

{%- set osrelease = salt['grains.get']('osrelease') %}

profile:
  web_jekyll:
    git_repos:
      news.opensuse.org:
        repo: https://github.com/openSUSE/news-o-o.git
      planet.opensuse.org:
        repo: https://github.com/openSUSE/planet-o-o.git
      search.opensuse.org:
        repo: https://github.com/openSUSE/search-o-o.git
      www-test.opensuse.org:
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
      debuginfod.opensuse.org:
        repo: https://github.com/openSUSE/debuginfod-o-o.git
      get.opensuse.org:
        repo: https://github.com/openSUSE/get-o-o.git
        branch: main
      universe.opensuse.org:
        repo: https://github.com/openSUSE/universe-o-o.git
        branch: main
      www.opensuse.org:
        repo: https://github.com/openSUSE/landing-page.git
        # www.o.o/openid/ is not handled by Jekyll, HAProxy forwards /openid/ to a different server
    server_list:
      - jekyll.infra.opensuse.org
      - narwal5.infra.opensuse.org
      - narwal6.infra.opensuse.org
      - narwal7.infra.opensuse.org
      - narwal8.infra.opensuse.org

zypper:
  repositories:
    devel:languages:ruby:
      baseurl: https://$mirror_ext/repositories/devel:/languages:/ruby/$releasever/
      priority: 100
      refresh: True

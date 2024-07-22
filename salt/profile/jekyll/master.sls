{%- from 'macros.jinja' import known_hosts %}
{% set git_repos = salt['pillar.get']('profile:web_jekyll:git_repos') %}

{%- set home = '/home/web_jekyll/' %}
{%- set gitroot = home ~ 'git/' %}

include:
  - profile.cron

jekyll_master_pgks:
  pkg.installed:
    - pkgs:
      - git
      - rsync
      - ruby3.1-devel
      # Needed for planet to work with its database
      - sqlite3-devel
      - libopenssl-devel
      - gcc
      - gcc-c++
      - make
      - tar
      - aspell-devel
      - aspell-en

/home/web_jekyll/.ssh/id_ed25519:
  file.managed:
    - contents_pillar: profile:web_jekyll:ssh_private_key
    - mode: '0600'
    - user: web_jekyll

{{ known_hosts(salt['pillar.get']('profile:web_jekyll:server_list'), 'web_jekyll') }}

{{ home }}bin:
  file.directory:
    - user: root

{{ home }}bin/fetch_build_and_rsync_jekyll:
  cron.present:
    - user: web_jekyll
    - minute: 0
  file.managed:
    - context:
        git_dirs: {{ git_repos }}
        server_list: {{ pillar['profile']['web_jekyll']['server_list'] }}
    - mode: '0755'
    - source: salt://profile/jekyll/files/git_pull_and_update.sh.jinja
    - template: jinja
    - user: root

{{ gitroot }}:
  file.directory:
    - user: web_jekyll

{{ home }}jekyll:
  file.directory:
    - user: web_jekyll

{{ home }}log:
  file.directory:
    - user: web_jekyll

# clone git repos
{% for dir, data in git_repos.items() %}
{{ data.repo }}:
  git.cloned:
    - branch: {{ data.get('branch', 'master') }}
    - target: {{ gitroot }}{{ dir }}
    - user: web_jekyll

{{ home }}jekyll/{{ dir }}:
  file.directory:
    - user: web_jekyll
{% endfor %}

{#- remove unmanaged repositories #}
{%- set repositories = git_repos.keys() %}
{%- for repository in salt['file.find'](gitroot, maxdepth=1, mindepth=1, print='name', type='d') %}
  {%- if repository not in repositories %}
jekyll_purge_{{ repository }}:
  file.absent:
    - names:
        - {{ gitroot }}{{ repository }}
        - {{ home }}jekyll/{{ repository }}
        - {{ home }}log/{{ repository }}.log
  {%- endif %}
{%- endfor %}

{% set git_repos = salt['pillar.get']('profile:web_jekyll:git_repos') %}

# Using rubygem() provides, because the rubygem packages have the ruby version in the package name
jekyll_master_pgks:
  pkg.installed:
    - pkgs:
      - git
      - rsync
      - rubygem\(jekyll\)

/home/web_jekyll/.ssh/id_ed25519:
  file.managed:
    - contents_pillar: profile:web_static:ssh_private_key
    - mode: 600
    - user: web_jekyll

/home/web_jekyll/.ssh/known_hosts:
  file.managed:
    - contents_pillar: profile:web_jekyll:ssh_known_hosts
    - mode: 644
    - user: root

/home/web_jekyll/bin:
  file.directory:
    - user: root

/home/web_jekyll/bin/fetch_build_and_rsync_jekyll:
  cron.present:
    - user: web_jekyll
    - minute: 0
  file.managed:
    - context:
      git_dirs: {{ git_repos }}
    - mode: 755
    - source: salt://profile/jekyll/files/git_pull_and_update.sh
    - template: jinja
    - user: root

/home/web_jekyll/git:
  file.directory:
    - user: web_jekyll

/home/web_jekyll/jekyll:
  file.directory:
    - user: web_jekyll

# clone git repos
{% for dir, data in git_repos.items() %}
{{ data.repo }}:
  # salt 2018.3.3 introduced git.cloned - switch once our salt is new enough
  git.latest:
    - branch: {{ data.get('branch', 'master') }}
    - target: /home/web_jekyll/git/{{ dir }}
    # When checking out a non-default branch, salt will create a local branch based on HEAD by default.
    # We need to specify "rev" to ensure we get the branch we want, and to make it tracking the branch from origin.
    - rev: {{ data.get('branch', 'master') }}
    - user: web_jekyll

/home/web_jekyll/jekyll/{{ dir }}:
  file.directory:
    - user: web_jekyll
{% endfor %}

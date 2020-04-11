{% set git_repos = salt['pillar.get']('profile:web_static:git_repos') %}

static_master_pgks:
  pkg.installed:
    - pkgs:
      - git
      - rsync

/home/web_static/.ssh/id_ed25519:
  file.managed:
    - contents_pillar: profile:web_static:ssh_private_key
    - mode: 600
    - user: web_static

/home/web_static/.ssh/known_hosts:
  file.managed:
    - contents_pillar: profile:web_static:ssh_known_hosts
    - mode: 644
    - user: root

/home/web_static/bin:
  file.directory:
    - user: root

static_master_cron_mailto:
  cron.env_present:
    - name: MAILTO
    - value: admin-auto@opensuse.org
    - user: web_static

/home/web_static/bin/fetch_and_rsync_static:
  cron.present:
    - user: web_static
    - minute: 0
  file.managed:
    - context:
      expected_gitmodules: {{ pillar['profile']['web_static']['expected_gitmodules'] }}
      server_list: {{ pillar['profile']['web_static']['server_list'] }}
      git_dirs: {{ git_repos }}
    - mode: 755
    - source: salt://profile/static/files/git_pull_and_update.sh
    - template: jinja
    - user: root

/home/web_static/git:
  file.directory:
    - user: web_static

# clone git repos
{% for dir, data in git_repos.items() %}
{{ data.repo }}:
  # salt 2018.3.3 introduced git.cloned - switch once our salt is new enough
  git.latest:
    - branch: {{ data.get('branch', 'master') }}
    - target: /home/web_static/git/{{ dir }}
    # When checking out a non-default branch, salt will create a local branch based on HEAD by default.
    # We need to specify "rev" to ensure we get the branch we want, and to make it tracking the branch from origin.
    - rev: {{ data.get('branch', 'master') }}
    - user: web_static
{% endfor %}

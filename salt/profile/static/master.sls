{% set git_repos = salt['pillar.get']('profile:web_static:git_repos') %}

include:
  - profile.cron

static_master_pgks:
  pkg.installed:
    - pkgs:
      - git

/home/web_static/.ssh/id_ed25519:
  file.managed:
    - contents_pillar: profile:web_static:ssh_private_key
    - mode: '0600'
    - user: web_static

/home/web_static/.ssh/known_hosts:
  file.managed:
    - mode: '0644'
    - user: root
    - replace: false

{%- for target, keys in salt['mine.get'](salt['pillar.get']('profile:web_static:server_list', []), 'ssh_host_keys', 'list').items() %}
{%- if 'ed25519.pub' in keys %}
web_static_known_hosts_{{ target }}:
  ssh_known_hosts.present:
    - name: {{ target }}
    - user: web_static
    - key: {{ keys['ed25519.pub'].split()[1] }}
    - enc: ssh-ed25519
    - hash_known_hosts: False
{%- endif %}
{%- endfor %}

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
    - mode: '0755'
    - source: salt://profile/static/files/git_pull_and_update.sh.jinja
    - template: jinja
    - user: root

/home/web_static/git:
  file.directory:
    - user: web_static

# clone git repos
{% for dir, data in git_repos.items() %}
{{ data.repo }}-{{ data.get('branch', 'master') }}:
  # salt 2018.3.3 introduced git.cloned - switch once our salt is new enough
  git.cloned:
    - name: {{ data.repo }}
    - branch: {{ data.get('branch', 'master') }}
    - target: /home/web_static/git/{{ dir }}
    - user: web_static
{% endfor %}

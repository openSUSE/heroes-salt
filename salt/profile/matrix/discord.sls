{% set roles = salt['grains.get']('roles', []) %}

discord_pgks:
  pkg.installed:
    - pkgs:
      - git
      - nodejs10
      - nodejs-common

/var/lib/matrix-synapse/discord:
  file.directory:
    - user: synapse

discord_conf_file:
  file.managed:
    - name: /var/lib/matrix-synapse/discord/config.yaml
    - source: salt://profile/matrix/files/config-discord.yaml
    - template: jinja
    - require:
      - file: /var/lib/matrix-synapse/discord
    - require_in:
      - service: discord_service
    - watch_in:
      - module: discord_restart

https://github.com/Half-Shot/matrix-appservice-discord.git:
  git.latest:
    - branch: master
    - target: /var/lib/matrix-synapse/discord/
    - rev: master
    - user: synapse

discord_boostrap:
  cmd.run:
    - name: npm install
    - cwd: /var/lib/matrix-synapse/discord
    - user: synapse
    - env: "NODE_VERSION=10"

discord_build:
  cmd.run:
    - name: npm run build
    - cwd: /var/lib/matrix-synapse/discord
    - user: synapse
    - env: "NODE_VERSION=10"

discord_systemd_file:
  file.managed:
    - name: /etc/systemd/system/discord.service
    - source: salt://profile/matrix/files/discord.service
    - require_in:
      - service: discord_service

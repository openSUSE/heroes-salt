{% set roles = salt['grains.get']('roles', []) %}

discord_pgks:
  pkg.installed:
    - pkgs:
      - git
      - nodejs10
      - npm10
      - nodejs-common
      - make
      - gcc
      - gcc-c++

/var/lib/matrix-synapse/discord:
  file.directory:
    - user: synapse

https://github.com/Half-Shot/matrix-appservice-discord.git:
  git.latest:
    - branch: master
    - target: /var/lib/matrix-synapse/discord/
    - rev: master
    - user: synapse

discord_conf_file:
  file.managed:
    - name: /var/lib/matrix-synapse/discord/config.yaml
    - source: salt://profile/matrix/files/config-discord.yaml
    - template: jinja
    - user: synapse
    - require:
      - file: /var/lib/matrix-synapse/discord
    - require_in:
      - service: discord_service
    - watch_in:
      - module: discord_restart

discord_appservice_file:
  file.managed:
    - name: /var/lib/matrix-synapse/discord/discord-registration.yaml
    - source: salt://profile/matrix/files/appservice-discord.yaml
    - user: synapse
    - require:
      - file: /var/lib/matrix-synapse/discord
    - watch_in:
      - module: discord_restart

discord_boostrap:
  cmd.run:
    - name: npm install
    - cwd: /var/lib/matrix-synapse/discord
    - runas: synapse
    - env:
      - NODE_VERSION: 10

discord_build:
  cmd.run:
    - name: npm run build
    - cwd: /var/lib/matrix-synapse/discord
    - runas: synapse
    - env:
      - NODE_VERSION: 10

discord_systemd_file:
  file.managed:
    - name: /etc/systemd/system/discord.service
    - source: salt://profile/matrix/files/discord.service
    - require_in:
      - service: discord_service

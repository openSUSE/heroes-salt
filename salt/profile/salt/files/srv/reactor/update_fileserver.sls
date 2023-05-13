{%- set deploy_password = salt['pillar.get']('profile:salt:reactor:update_fileserver_deploy_password', '') -%}
{%- raw -%}
{%- if data.data == "{% endraw %}{{ deploy_password }}{% raw %}" -%}
update_fileserver:
  runner.fileserver.update: []
  runner.git_pillar.update: []

update_fileserver_ng:
  local.state.apply:
    - tgt: {{ grains['master'] }}
    - args:
      - mods: profile.salt.git.update
{%- endif -%}
{%- endraw -%}

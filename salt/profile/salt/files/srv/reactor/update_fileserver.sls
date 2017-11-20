{%- set deploy_password = salt['pillar.get']('profile:salt:reactor:update_fileserver_deploy_password', '') -%}
{%- raw -%}
{%- if data.data == "{% endraw %}{{ deploy_password }}{% raw %}" -%}
update_fileserver:
  runner.fileserver.update: []
  runner.git_pillar.update: []
{%- endif -%}
{%- endraw -%}

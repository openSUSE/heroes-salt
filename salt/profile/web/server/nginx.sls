{% set csr_dict = salt['pillar.get']('profile:web:server:nginx:csr', {}) %}

include:
  - nginx.ng

nginx_vim_plugin:
  pkg.installed:
    - name: vim-plugin-nginx

{% for domain, csr in csr_dict.items() %}
/etc/nginx/ssl/{{ domain }}.csr:
  file.managed:
    - contents_pillar: profile:web:server:nginx:csr:{{ domain }}
{% endfor %}

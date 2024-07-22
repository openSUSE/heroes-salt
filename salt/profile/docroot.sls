{%- set websites = {
      'web_jekyll': salt['pillar.get']('profile:web_jekyll:websites', []),
      'web_static': salt['pillar.get']('profile:web_static:websites', []),
    }
%}

{%- set exclusions = ['oom'] %}

{%- set vhroot = '/srv/www/vhosts/' %}
{%- set domain = '.opensuse.org' %}

docroot_top:
  file.directory:
    - name: {{ vhroot }}

{%- for user, sites in websites.items() %}
  {%- for site in sites %}
    {%- if site not in exclusions %}
docroot_{{ site }}:
  file.directory:
    - name: {{ vhroot }}{{ site }}{{ domain }}
    - user: {{ user }}
    - require:
        - file: docroot_top
    {%- endif %}
  {%- endfor %}
{%- endfor %}

{#- remove unmanaged docroots #}
{%- set all_sites = websites['web_jekyll'] + websites['web_static'] %}
{%- for docroot in salt['file.find'](vhroot, maxdepth=1, mindepth=1, print='name', type='d') %}
  {%- if docroot.replace(domain, '') not in all_sites %}
docroot_purge_{{ docroot }}:
  file.absent:
    - name: {{ vhroot }}{{ docroot }}
  {%- endif %}
{%- endfor %}

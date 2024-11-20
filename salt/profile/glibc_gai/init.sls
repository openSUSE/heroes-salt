{%- if 'gateway' in pillar.get('roles', []) %}

/etc/gai.conf:
  file.managed:
    - source: salt://profile/glibc_gai/files/gai.conf.jinja
    - template: jinja

{%- else %}

/etc/gai.conf:
  file.absent

{%- endif %}

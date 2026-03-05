/usr/local/sbin/update-os:
  file.managed:
    - source: salt://{{ slspath }}/files/update-os.sh.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: '0744'

{%- set latest = '16.0' %}
{%- set previous = '15.6' %}

/usr/local/sbin/upgrade-os:
{%- if grains['osrelease'] == latest or grains['osfullname'] != 'Leap' %}
  file.absent
{%- else %}
  file.managed:
    - source: salt://{{ slspath }}/files/upgrade-os.sh.jinja
    - template: jinja
    - context:
        latest_version: '{{ latest }}'
        previous_version: '{{ previous }}'
    - user: root
    - group: root
    - mode: '0755'
{%- endif %}

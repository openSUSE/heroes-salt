{%- if 'motd' in pillar %}

{%- if grains['osfullname'] == 'Leap' and grains['osrelease'] | float < 16 %}
/etc/motd:
  file.prepend:
    - header: {{ not opts['test'] }}
    - text: {{ pillar['motd'] }}

/etc/motd_fun:
  file.append:
    - name: /etc/motd
    - text: Have a lot of fun ...

{%- else %}
/etc/motd:
  file.absent

/etc/motd.d/00_salt:
  file.managed:
    - contents_pillar: motd

{%- endif %} {#- close OS checks #}

{%- endif %} {#- close pillar check #}

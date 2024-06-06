{%- set xinetdd = '/etc/xinetd.d/' %}
{%- set test = opts['test'] %}

remove_legacy_monitoring_stuff:
  file.absent:
    - names:
        - /etc/monitoring-plugins
        - /etc/nrpe.cfg
        - /etc/nrpe.cfg.rpmnew
        - /etc/nrpe.cfg.rpmsave
        - /etc/nrpe.d
        - {{ xinetdd }}check_mk
        - {{ xinetdd }}nrpe
        - {{ xinetdd }}nrpe.rpmnew
        - {{ xinetdd }}nrpe.rpmsave

{%- set fe = salt['file.file_exists'] %}
{%- if not ( fe(xinetdd ~ 'csync2') or fe(xinetdd ~ 'vsftpd') or fe(xinetdd ~ 'livestatus') ) %}
xinetd:
  pkg.removed: []
  {%- if not test %}
  service.dead:
    - enable: False
  {%- endif %}
{%- endif %}

{%- if not test %}
nrpe:
  service.dead:
    - enable: False
    - require_in:
        - remove_legacy_monitoring_stuff
{%- endif %}

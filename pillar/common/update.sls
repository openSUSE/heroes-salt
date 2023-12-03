{%- set host_index  = grains['host'][-1] %}
{%- set padding     = '%02d' %}

{%- if host_index.isdigit() %}
{%- set hour        = ( ( host_index | int * 15 ) / 60 ) %}
{%- else %}
{%- set hour        = 0 %}
{%- set host_index  = 1 %}
{%- endif %}

{%- set minute      = ( ( host_index | int * 15 ) % 60 ) %}
{%- set minute_plus = padding % ( minute + 5 ) %}
{%- set minute      = padding % minute %}

{%- set update_time = padding % hour ~ ':' ~ minute %}
{%- set reboot_time = padding % hour ~ ':' ~ minute_plus %}

os-update:
  time: {{ update_time }}
  reboot_cmd: rebootmgr
  {%- if grains.get('osfullname') == 'openSUSE Leap' %}
  update_cmd: security
  {%- endif %}
  ignore_services_from_restart:
    - dbus
 
rebootmgr:
  window-start: {{ reboot_time }}
  window-duration: 10m
  {%- if not grains.get('reboot_safe', True) %}
  strategy: 'off'
  {%- endif %}

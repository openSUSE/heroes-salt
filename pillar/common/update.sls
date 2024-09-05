{%- set reboot_safe = grains.get('reboot_safe', True) %}
{%- set host_index  = grains['host'][-1] %}
{%- set padding     = '%02d' %}

{%- if host_index.isdigit() %}
{%- set hour        = host_index | int %}
{%- else %}
{%- set hour        = 0 %}
{%- set host_index  = 1 %}
{%- endif %}

{%- set minute      = 15 %}
{%- set minute_plus = padding % ( minute + 5 ) %}
{%- set minute      = padding % minute %}

{%- set update_time = padding % hour ~ ':' ~ minute %}
{%- set reboot_time = padding % hour ~ ':' ~ minute_plus %}

os-update:
  time: {{ update_time }}
  randomizeddelaysec: 300
  reboot_cmd: rebootmgr
  {%- if grains.get('osfullname') == 'Leap' and not reboot_safe %}
  update_cmd: security
  {%- endif %}
  ignore_services_from_restart:
    - dbus

rebootmgr:
  window-start: {{ reboot_time }}
  window-duration: 10m
  {%- if not reboot_safe %}
  strategy: 'off'
  {%- endif %}

profile:
  buddycheck:
    services:
      - os-update

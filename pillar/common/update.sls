os-update:
  time: 00:30
  reboot_cmd: rebootmgr
  {%- if grains.get('osfullname') == 'openSUSE Leap' %}
  update_cmd: security
  {%- endif %}
 
rebootmgr:
  window-start: 01:00
  window-duration: 1h
  {%- if not grains.get('reboot_safe', True) %}
  strategy: 'off'
  {%- endif %}

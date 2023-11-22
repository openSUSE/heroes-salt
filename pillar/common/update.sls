os-update:
  time: 00:30
  reboot_cmd: rebootmgr
  {%- if grains.get('osfullname') == 'openSUSE Leap' %}
  update_cmd: security
  {%- endif %}
  ignore_services_from_restart:
    - dbus
 
rebootmgr:
  window-start: 01:00
  window-duration: 1h
  {%- if not grains.get('reboot_safe', True) %}
  strategy: 'off'
  {%- endif %}

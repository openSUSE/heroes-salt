{#-
  Issue:
  "service.running" with "enable: true" will not enable a service on Micro, the complete step is skipped due to being run in "offline" mode
  this mode is expected inside the transactional update, but the "enable" part should be technically possible to run without systemd being live ...
  https://github.com/saltstack/salt/issues/62311#issuecomment-1747222942

  Time for ugly workarounds!
#}

enable_salt-minion:
  file.symlink:
    - name: /etc/systemd/system/multi-user.target.wants/salt-minion.service
    - target: /usr/lib/systemd/system/salt-minion.service
    - order: last

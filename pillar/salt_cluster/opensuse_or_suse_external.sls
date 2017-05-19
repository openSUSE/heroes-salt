{% if 'ntp' not in salt['grains.get']('roles' ,[]) %}
ntp:
  ng:
    settings:
      ntp_conf:
        restrict:
          - rolex.opensuse.org
          - lange.opensuse.org
        server:
          - rolex.opensuse.org iburst
          - lange.opensuse.org iburst
{% endif %}

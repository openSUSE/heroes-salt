{% if 'ntp' not in salt['grains.get']('roles' ,[]) %}
ntp:
  ng:
    settings:
      ntp_conf:
        restrict:
          - ntp1.infra.opensuse.org
          - ntp2.infra.opensuse.org
        server:
          - ntp1.infra.opensuse.org iburst
          - ntp2.infra.opensuse.org iburst
{% endif %}

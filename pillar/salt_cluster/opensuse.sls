{% if 'ntp' not in salt['grains.get']('roles' ,[]) %}
ntp:
  ng:
    settings:
      ntp_conf:
        server:
          - ntp1.infra.opensuse.org iburst
          - ntp2.infra.opensuse.org iburst
          - ntp3.infra.opensuse.org iburst
{% endif %}
salt:
  minion:
    master: minnie.infra.opensuse.org

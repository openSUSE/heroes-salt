{%- if salt['grains.get']('include_secrets', True) %}
include:
  - secrets.role.devcon
{%- endif %}

profile:
  authorized-exec:
    certificate_deployment:
      cert:
        commands:
          - '/usr/local/bin/update-ontap-certificate (?:--host [\w\.-]+\.mgmt\.infra.opensuse\.org )?--certificate-chain-file /etc/ssl/services/[\w\.-]+/fullchain\.pem --key-file /etc/ssl/services/[\w\.-]+/privkey\.pem --purpose (?:rest|s3)'
  dehydrated:
    netrc:
      netapp-fas-prg2.mgmt.infra.opensuse.org:
        login: opensuse-svc-cert

zypper:
  packages:
    # for update-ontap-certificate.py
    python3-pem: {}

network:
  config:
    netconfig_dns_resolver_options:
      - trust-ad

ssh_config:
  CanonicalDomains: infra.opensuse.org
  CanonicalizeHostname: true
  PreferredAuthentications: publickey
  StrictHostKeyChecking: true
  VerifyHostKeyDNS: true

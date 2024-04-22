network:
  config:
    netconfig_dns_resolver_options:
      - trust-ad

ssh_config:
  PreferredAuthentications: publickey
  StrictHostKeyChecking: true
  VerifyHostKeyDNS: true

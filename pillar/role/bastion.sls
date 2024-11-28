include:
  - role.common.dns_ssh

ssh_config:
  CanonicalDomains: infra.opensuse.org
  CanonicalizeHostname: true
  PreferredAuthentications: publickey
  StrictHostKeyChecking: true

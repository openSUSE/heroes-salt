#!py

import yaml

base = '/srv/pillar/infra/certificates/'
cas  = ['letsencrypt-test', 'letsencrypt', 'heroes']

_certificates = {}
_services = []

def _extend_services(low_services):
  for service in low_services:
    if service not in _services:
      _services.append(service)

def run():
  result = {}
  host = __grains__['host']

  certificates = {}
  """
  target deployment does not support one certificate name being issued from multiple CAs
  duplicates should already be prevented on a YAML validation level, but merging will happen in the order of "cas"
  """
  for file in cas:
    with open(f'{base}{file}.yaml') as fh:
      certificates.update(yaml.safe_load(fh))
  with open(f'{base}macros.yaml') as fh:
    macros = yaml.safe_load(fh)

  for certificate, certificate_config in certificates.items():
    for target in certificate_config['targets']:

      if host == target.get('host'):
        _certificates.update({certificate: target.get('services', [])})
        _extend_services(target.get('services', []))

      if 'macro' in target and target.get('macro') in macros:
        macro_config = macros[target['macro']]

        if host in macro_config['hosts']:
          if certificate in _certificates:
            _certificates[certificate].extend(macro_config['services'])
          else:
            _certificates.update({certificate: macro_config['services']})
          _extend_services(macro_config['services'])

  if _certificates:
    commands = [
      '/usr/bin/systemctl try-reload-or-restart ' + service for service in _services
    ]

    result.update({
      'users': {
          'cert': {
              'fullname': 'Certificate Deployment User',
              'shell': '/bin/sh',
              'ssh_auth_file': [
                'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOXfogRapqcAJJOe1S+EYSrFLeNN+1MxDHnfav443GaM dehydrated@acme',
              ],
          },
      },
      'sudoers': {
        'users': {
          'cert': [
            f'{host}=(root) NOPASSWD: {", ".join(commands)}',
          ],
        },
      },
      'profile': {
        'certificate_target': {
          'certificates': _certificates,
        },
      },
      'zypper': {
        'packages': {
          'acl': {},
        },
      },
    })

  return result

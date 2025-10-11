#!py

import yaml

root = '/srv/pillar/'
base = f'{root}infra/certificates/'
cas  = ['letsencrypt-test', 'letsencrypt', 'heroes']

_certificate_targets = []
_certificates = {}
_services = []

# services which use a special command instead of sudo based service reload
# entries here go along with a conditional in salt/profile/dehydrated/files/etc/dehydrated/hook.d/certificate.sh.jinja
_service_excludes = [
  'mariadb',
]

def _extend_services(low_services):
  for service in low_services:
    if service not in _services and service not in _service_excludes:
      _services.append(service)

def run():
  result = {}
  host = __grains__['host']
  minion_id_struct = __salt__['slsutil.renderer']('{}id/{}.sls'.format(root, __grains__['id'].replace('.', '_')))

  collect_targets = 'gateway' in minion_id_struct.get('roles', [])

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
      match = False
      target_services = target.get('services', [])

      if 'macro' in target and target['macro'] in macros:
        macro_config = macros[target['macro']]

        if host in macro_config['hosts']:
          match = True
          target_services = target_services + macro_config['services']

        if collect_targets:
          for macro_host in macro_config['hosts']:
            if macro_host not in _certificate_targets:
              _certificate_targets.append(macro_host)

      target_host = target.get('host')
      if match or host == target_host:
        if certificate in _certificates:
          _certificates[certificate].extend(target_services)
        else:
          _certificates.update({certificate: target_services})
        _extend_services(target_services)

      if collect_targets and target_host is not None and target_host not in _certificate_targets:
        _certificate_targets.append(target_host)

  if _certificates:
    commands = [
      '/usr/bin/systemctl try-reload-or-restart ' + service for service in _services
    ]
    commands_auth = [
      fr'systemctl is-active --quiet {service} \|\| exit "\$\?" ; sudo systemctl try-reload-or-restart {service}'  # noqa W605
      for service in _services
    ]

    # we use internal-sftp by default, but for restriction as a forced command set the external binary instead
    if __grains__['osfullname'] == 'Leap':
      sftp = '/usr/lib/ssh/sftp-server'
    elif __grains__['osfullname'] == 'openSUSE Tumbleweed':
      sftp = '/usr/libexec/ssh/sftp-server'

    result.update({
      'users': {
          'cert': {
              'fullname': 'Certificate Deployment User',
              'shell': '/bin/sh',
              'ssh_auth_file': [
                'command="authorized-exec /etc/authorized-exec/certificate_deployment",restrict ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOXfogRapqcAJJOe1S+EYSrFLeNN+1MxDHnfav443GaM dehydrated@acme',
              ],
          },
      },
      'profile': {
        'authorized-exec': {
          'certificate_deployment': {
            'cert': {
              'commands': [
                f'{sftp} ?',
                r'systemctl is-active --quiet mariadb \|\| exit "\$\?" ; mariadb-admin -S /run/mysql/mysql.sock --connect-timeout=10 --wait=2 flush-ssl',  # noqa W605
              ],
            },
          },
        },
        'certificate_target': {
          'certificates': _certificates,
        },
      },
      'sshd_config': {
        'matches': {
          'certificate deployment': {
            'type': {
              'User': 'cert',
            },
            'options': {
               'Subsystem': f'sftp {sftp}',
            },
          },
        },
      },
      'zypper': {
        'packages': {
          'acl': {},
        },
      },
    })

    if commands:
      result['sudoers'] = {
        'users': {
          'cert': [
            f'{host}=(root) NOPASSWD: {", ".join(commands)}',
          ],
        },
      }
      result['profile']['authorized-exec']['certificate_deployment']['cert']['commands'].extend(commands_auth)

  if collect_targets:
    if 'profile' in result and 'certificate_target' in result['profile']:
      result['profile']['certificate_target']['targets'] = _certificate_targets
    else:
      result.update({
        'profile': {
          'certificate_target': {
            'targets': _certificate_targets,
          },
        },
      })

  return result

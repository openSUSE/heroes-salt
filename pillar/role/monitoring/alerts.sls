#!py

import yaml


def run():
  rules = {
    'prometheus': {
      'extra_files': {},
    },
  }
  for file in ['base', 'prometheus']:
    with open(f'/srv/pillar/infra/alerts/{file}.yaml') as fh:
      rules['prometheus']['extra_files'].update(
        {
          f'rules_{file}': {
            'file': f'rules/{file}',
            'component': 'prometheus',
            'config': yaml.safe_load(fh),
          },
        },
      )

  return rules

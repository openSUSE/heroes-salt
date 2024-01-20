#!py

import yaml


def run():
  with open('/srv/pillar/infra/alerts.yaml') as fh:
    rules = yaml.safe_load(fh)

  return {
    'prometheus': {
      'extra_files': {
        'rules_base': {
          'file': 'rules/base',
          'component': 'prometheus',
          'config': rules,
        },
      },
    },
  }

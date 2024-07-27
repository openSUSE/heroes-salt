#!py

from itertools import chain

def run():
  states = {}

  website_roles = [
    'web_jekyll',
    'web_static',
  ]

  exclusions = [
    'oom',
  ]

  vhroot = '/srv/www/vhosts/'
  domain = '.opensuse.org'

  websites = {
    role: __salt__['pillar.get'](f'profile:{role}:websites', [])
    for role in website_roles
  }

  states['docroot_top'] = {
    'file.directory': [{
      'name': vhroot,
    }],
  }

  for user, sites in websites.items():
    for site in sites:
      if site not in exclusions:
        states[f'docroot_{site}'] = {
          'file.directory': [{
            'name': f'{vhroot}{site}{domain}',
            'user': user,
            'require': [{
              'file': 'docroot_top',
            }],
          }],
        }

  # remove unmanaged docroots
  all_sites = list(chain(*websites.values()))
  for docroot in __salt__['file.find'](vhroot, maxdepth=1, mindepth=1, print='name', type='d'):
    if docroot.replace(domain, '') not in all_sites:
      states[f'docroot_purge_{docroot}'] = {
        'file.absent': [{
          'name': f'{vhroot}{docroot}',
        }],
      }

  return states

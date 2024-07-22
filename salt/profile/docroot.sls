#!py

def run():
  states = {}

  websites = {
    'web_jekyll': __salt__['pillar.get']('profile:web_jekyll:websites', []),
    'web_static': __salt__['pillar.get']('profile:web_static:websites', []),
  }

  exclusions = [
    'oom',
  ]

  vhroot = '/srv/www/vhosts/'
  domain = '.opensuse.org'

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
  all_sites = [ site for _, sites in websites.items() for site in sites ]

  for docroot in __salt__['file.find'](vhroot, maxdepth=1, mindepth=1, print='name', type='d'):
    if docroot.replace(domain, '') not in all_sites:
      states[f'docroot_purge_{docroot}'] = {
        'file.absent': [{
          'name': f'{vhroot}{docroot}',
        }],
      }

  return states

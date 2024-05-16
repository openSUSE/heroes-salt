#!py

from re import search


def run():
  states = {}

  spn_regex = r'spn=([\w\.-]+)@infra\.opensuse\.org,o=heroes'  # is there a way to fetch only the short names from kani?

  users = __salt__['ldap3.search'](
    {'url': 'ldaps://ldap.infra.opensuse.org'},
    base='o=heroes',
    scope='onelevel',
    filterstr='cn=vpn',
    attrlist=['member'],
  ).get(
    'spn=vpn@infra.opensuse.org,o=heroes', {},
  ).get(
    'member', [],
  )

  prefixes = {
    'tcp': '2a07:de40:b27e:5002::',
    'udp': '2a07:de40:b27e:5001::',
  }

  protocols = prefixes.keys()

  dir_etc = '/etc/openvpn/'
  dirs_ccd = {
    protocol: dir_etc + f'ccd-{protocol}/'
    for protocol in protocols
  }

  check_cmd = 'awk "/^ifconfig/{ print $2 }" '

  ccds = {
    'desired': [],
    'existing': sorted(set(__salt__['file.find'](dir_etc + 'ccd-*/', type='f', print='name'))),
  }

  states['openvpn_ccd_directories'] = {
    'file.directory': [
      {'names': list(dirs_ccd.values())},
    ],
  }

  ccd_files = []

  for user in sorted(users):
    user = search(spn_regex, user.decode()).group(1)
    ccds['desired'].append(user)

    if all(__salt__['file.file_exists'](dirs_ccd[protocol] + user) for protocol in protocols):
      addresses = {
        protocol: __salt__['cmd.run'](check_cmd + dirs_ccd[protocol] + user)
        for protocol in protocols
      }

    else:
      addresses = {
        protocol: __salt__['os_network.sixify'](user, prefixes[protocol])
        for protocol in protocols
      }

    for protocol in protocols:
      ccd_files.append(
        {
          dirs_ccd[protocol] + user: [
            {
              'context': {
                'address': addresses[protocol],
                'prefix': prefixes[protocol],
              },
            },
          ],
        }
      )

  states['openvpn_ccd_files'] = {
    'file.managed': [
      {'names': ccd_files},
      {'source': 'salt://profile/vpn/openvpn/files/ccd.jinja'},
      {'template': 'jinja'},
      {'require': [
        {'file': 'openvpn_ccd_directories'},
      ]},
    ],
  }

  bad_ccds = [ccd for ccd in ccds['existing'] if ccd not in ccds['desired']]
  if bad_ccds:
    states['openvpn_ccd_bad_files'] = {
      'file.absent': [
        {'names': [
          dirs_ccd[protocol] + user for user in bad_ccds for protocol in protocols
        ]},
      ],
    }

  return states

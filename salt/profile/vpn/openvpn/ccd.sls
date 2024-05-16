#!py

from datetime import datetime
from re import search

# no ISO 8601 parsing in datetime with Python 3.6 yet
from dateutil import parser as dateparser


def run():
  states = {}
  now = datetime.now()

  ldap = {
    'url': 'ldaps://ldap.infra.opensuse.org',
    'common': {
      'base': 'o=heroes',
      'scope': 'onelevel',
    },
  }

  spn_regex = fr'spn=([\w\.-]+)@infra\.opensuse\.org,{ldap["common"]["base"]}'  # is there a way to fetch only the short names from kani?


  def has_expired(user_spn):

    # LDAP secrets are not available in the test environment
    if __grains__['id'].startswith('runner-') and __opts__['test']:
      return None

    user_expiry = __salt__['ldap3.search'](
      {
        'url': ldap['url'],
        'bind': {
          'method': 'simple',
          'password': __salt__['pillar.get']('profile:vpn:openvpn:ldap'),
        },
        'dn': 'dn=token',
      },
      **ldap['common'],
      filterstr=user_spn.replace(',' + ldap['common']['base'], ''),
      attrlist=[
        'account_expire',
      ],
    ).get(
      user_spn, {},
    ).get(
      'account_expire', [],
    )

    __salt__['log.debug'](f'openvpn.ccd: expiry of user {user_spn}: {user_expiry}')

    if user_expiry:
      return dateparser.parse(user_expiry[0], ignoretz=True) < now

    else:
      return False


  users = __salt__['ldap3.search'](
    {
      'url': ldap['url'],
    },
    **ldap['common'],
    filterstr='cn=vpn',
    attrlist=[
      'member',
    ],
  ).get(
    f'spn=vpn@infra.opensuse.org,{ldap["common"]["base"]}', {},
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
    user_spn = user.decode()
    user = search(spn_regex, user_spn).group(1)

    if not has_expired(user_spn):
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
          },
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

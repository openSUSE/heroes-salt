#!py

def run():
  states = {
    'vpn_ca_packages': {
      'pkg.installed': [
        {'pkgs': ['easy-rsa']},
      ],
    },
    'vpn_ca_vars': {
      'file.managed': [
        {'name': '/etc/easy-rsa/vars'},
        {'source': 'salt://profile/vpn/openvpn/files/easy-rsa/vars.jinja'},
        {'template': 'jinja'},
        {'require': [
          {'pkg': 'vpn_ca_packages'},
        ]},
      ],
    },
  }

  return states

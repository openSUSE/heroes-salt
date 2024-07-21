#!py

from yaml import safe_load


def run():
  with open('/srv/pillar/infra/wireguards.yaml') as fh:
    data = safe_load(fh)

  my_host = __grains__['host']
  pillar = {}

  for group in data:
    if my_host in group:
      my_config = group[my_host]
      interface = my_config['interface']

      peers = []
      for host, config in group.items():
        if host != my_host:
          peerdata =  {
              'PublicKey': config['public_key'],
              # note we do not use AllowedIPs for routing
              'AllowedIPs': ['::/0', '0.0.0.0/0'],
              'PersistentKeepalive': 30,
          }

          # either specify a specific endpoint using its name in the group
          if 'endpoint' in config:
            peerdata.update(
              {
                'Endpoint': group[config['endpoint']]['listen'],
              },
            )
          # or have the first fitting one picked (useful for groups with only two peers)
          else:
            for host, config in group.items():
              if host != my_host:
                if 'listen' in config and isinstance(config['listen'], str):
                  peerdata.update(
                    {
                      'Endpoint': config['listen'],
                    },
                  )
                  break

          peers.append(peerdata)

      pillar.update(
        {
          interface: {
            'config': {
              'Address': my_config['addresses'],
              'Table': False,
              'PostUp': "sh -c 'sleep 2 && ip a a " + my_config['link_local'] + f" dev {interface}'",
            },
            'peers': peers,
          },
        },
      )
      if 'listen' in my_config:
        pillar[interface].update(
          {
            'ListenPort': my_config['listen'].rpartition(':')[2],
          },
        )

  return {
    'wireguard': {
      'interfaces': pillar,
    },
  }

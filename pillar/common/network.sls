#!py
from opensuse_infrastructure_formula.pillar import common, network
from yaml import safe_load


def run():
    domain = __grains__['domain']
    host = __grains__['host']
    site = __grains__.get('site')

    pillar = network.generate_network_pillar(
            ['infra.opensuse.org'],
            domain, host, site,
    )

    if not pillar:
        pillar = {'network': {}}

    with open(common.pillar_domain_path(domain) + '/nameservers.yaml') as fh:
       site_nameservers = safe_load(fh)

    # common local resolver configuration
    __salt__['log.error'](site)
    __salt__['log.error'](site_nameservers)
    if site in site_nameservers:
        pillar['network'].update({
            'config': {
              'netconfig_dns_static_servers': site_nameservers[site],
              'netconfig_dns_static_searchlist': domain,
              'netconfig_dns_resolver_options': [
                  'rotate',
                  'timeout:3',
              ],
            },
        })

    # custom configuration for the legacy Nuremberg (QSC) site (excluding hypervisors there)
    if site == 'nue-ipx' and host not in ['slimhat', 'stonehat'] and __grains__['ip6_gw']:
        if 'routes' not in pillar['network']:
            pillar['network']['routes'] = {}

        # install default routes on machines which use external default gateways
        pillar['network']['routes'].update({
            'default4': {
                'gateway': '62.146.92.201',
            },
            'default6': {
                'gateway': '2a01:138:a004::1',
            },
        })

        # and install legacy internal routes through stonehat on such machines for them to reach internal services in other sites
        pillar['network']['routes'].update({
            destination_network: {
                'gateway': '192.168.87.1',
            } for destination_network in [
                '172.16.164.0/24',   # v PRG2 NAT64
                '172.16.130.0/24',   # v PRG2 os-public
                '172.16.201.0/31',   # os-p2p-nue1/1
                '172.16.202.0/31',   # os-p2p-nue1/2
                '192.168.252.0/24',  # ???
                '192.168.253.0/24',  # ???
                '192.168.254.0/24',  # ???
              ]
        })

        """
        for machines in locations we have not yet equipped with internal IPv6 routing,
        but which have an IPv6 route to the internet, install a blackhole route to our os-internal, os-kani, os-netbox and os-salt networks in PRG2
        this allows machines in these locations which have an IPv6 route to the internet to communicate with internal
        services in PRG2 via IPv4 instead of sending affected packets to the internet
        (which either leads to timeouts or stuck sessions, since we do not allow internal services to be reached over the internet)
        """
        pillar['network']['routes'].update({
            f'{prefix}/64': {
                'options': [
                    'blackhole',
                ],
            } for prefix in [
                '2a07:de40:b27e:1200::',
                '2a07:de40:b27e:1203::',
                '2a07:de40:b27e:1210::',
                '2a07:de40:b27e:1211::',
            ]
        })

    return pillar

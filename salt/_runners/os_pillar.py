"""
Extension module for fetching host configuraton data from hosts.yaml

Author: Georg Pfuetzenreuter <mail+opensuse@georg-pfuetzenreuter.net>

Copyright (C) 2023 openSUSE contributors

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

import yaml

repository = '/srv/salt-git'
file_root = f'{repository}/salt'
pillar_root = f'{repository}/pillar'


def _load(dataset):
    with open(f'{pillar_root}/infra/{dataset}.yaml') as fh:
        return yaml.safe_load(fh)


def _load_hosts():
    return _load('hosts')


def _load_networks():
    return _load('networks')


def get_host(host):
    hosts = _load_hosts()
    return hosts.get(host, {})


def get_host_interfaces(host):
    return get_host(host).get('interfaces', {})


def get_host_primary_interface(host):
    config = get_host(host)
    interfaces = config.get('interfaces', {})

    if 'primary_interface' in host:
        primary_interface = host['primary_interface']
    elif len(interfaces) == 1 :
        primary_interface = list(interfaces.keys())[0]
    else:
        primary_interface = 'eth0'

    return interfaces.get(primary_interface, {})


def get_host_disks(host):
    return get_host(host).get('disks', {})


def get_host_ips(host):
    config = get_host_primary_interface(host)
    result = {'ip4': None, 'ip6': None, 'pseudo_ip4': None}
    result['ip4'] = config.get('ip4')
    result['ip6'] = config.get('ip6')
    result['pseudo_ip4'] = config.get('pseudo_ip4')

    return result


def get_host_ip4(host, strip_cidr=False):
    address = get_host_ips(host).get('ip4')
    if strip_cidr and address is not None:
        address = __salt__['salt.cmd']('os_network.strip_cidr', address)
    return address


def get_host_ip6(host, strip_cidr=False):
    address = get_host_ips(host).get('ip6')
    if strip_cidr and address is not None:
        address = __salt__['salt.cmd']('os_network.strip_cidr', address)
    return address


def get_host_pseudo_ip4(host):
    config = get_host_ips(host)
    return config.get('pseudo_ip4')


def get_network(country, name):
    config = _load_networks()
    return config.get(country, {}).get(name, {})


def get_host_ip4to6(host, prefix=None, network=None):
    host_config = get_host_ip4(host)
    if host_config is not None:
        if prefix is None:
            if network is None:
                network = 'openSUSE-NAT46-Pool'
            prefix = get_network('pseudo', network).get('net6')
        if prefix is not None:
            return __salt__['salt.cmd']('os_network.convert_4to6', __salt__['salt.cmd']('os_network.strip_cidr', host_config), prefix)
    return None

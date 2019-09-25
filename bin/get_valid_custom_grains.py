#!/usr/bin/python3

# For description and usage, see the argparse options at the end of the file

import argparse
import yaml


def get_valid_custom_grains():
    with open('pillar/valid_custom_grains.yaml', 'r') as f:
        VALID_CUSTOM_GRAINS = yaml.safe_load(f)

    return VALID_CUSTOM_GRAINS


def get_valid_global_grains():
    return get_valid_custom_grains()['global']


def get_all_valid_localized_grains():
    return get_valid_custom_grains()['localized']


def get_virt_cluster_only_physical():
    virt_cluster_only_physical = ''
    try:
        virt_cluster_only_physical = get_valid_custom_grains()['virt_cluster_only_physical']
    except KeyError:
        pass
    print('\n'.join(virt_cluster_only_physical))


def get_all_valid_domains(country):
    all_valid_domains = get_all_valid_localized_grains()[country]['domains']
    if type(all_valid_domains) == str:
        # convert to list
        all_valid_domains = [all_valid_domains]
    print('\n'.join(all_valid_domains))


def get_default_domain(country):
    print(get_all_valid_localized_grains()[country]['default_domain'])


def get_default_virt_cluster():
    results = []
    all_valid_localized_grains = get_all_valid_localized_grains()
    for country, items in all_valid_localized_grains.items():
        results.append('%s,%s,%s' % (country, items['city'], items['default_virt_cluster']))
    print('\n'.join(results))


def print_valid_localized_grains():
    results = []
    all_valid_localized_grains = get_all_valid_localized_grains()
    for country, items in all_valid_localized_grains.items():
        if type(items['virt_cluster']) == str:
            # convert to list
            items['virt_cluster'] = [ items['virt_cluster'] ]
        if type(items['virt_cluster']) == list:
            for virt_cluster in items['virt_cluster']:
                results.append('%s,%s,%s' % (country, items['city'], virt_cluster))
        else:
            raise Exception('virt_cluster "%s" is not a string or a list' % items['virt_cluster'])
    print('\n'.join(results))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter, description='Loads the pillar/valid_custom_grains.py and returns a list of valid custom grains in the form of "country,city,virt_cluster".')
    parser.add_argument('-p', action='store_true', help='Returns a list of physical machines that do not host any salt-managed VMs.')
    parser.add_argument('-d', nargs=1, help='Returns a list of the valid domains of a location.')
    parser.add_argument('--default-domain', nargs=1, help='Returns the default domain of a location.')
    parser.add_argument('-v', action='store_true', help='Returns the valid custom grains, but only displaying once each country with their default virt_cluster.')
    args = parser.parse_args()

    if args.p:
        get_virt_cluster_only_physical()
    elif args.d:
        get_all_valid_domains(args.d[0])
    elif args.default_domain:
        get_default_domain(args.default_domain[0])
    elif args.v:
        get_default_virt_cluster()
    else:
        print_valid_localized_grains()

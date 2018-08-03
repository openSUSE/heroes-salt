#!/usr/bin/python3

# For description and usage, see the argparse options at the end of the file

import argparse
import yaml


def get_valid_custom_grains():
    with open('pillar/valid_custom_grains.yaml', 'r') as f:
        VALID_CUSTOM_GRAINS = yaml.load(f)

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
    args = parser.parse_args()

    if args.p:
        get_virt_cluster_only_physical()
    else:
        print_valid_localized_grains()

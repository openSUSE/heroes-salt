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


def get_all_valid_domains(country):
    all_valid_domains = get_all_valid_localized_grains()[country]['domains']
    if type(all_valid_domains) == str:
        # convert to list
        all_valid_domains = [all_valid_domains]
    print('\n'.join(all_valid_domains))


def get_default_domain(country):
    print(get_all_valid_localized_grains()[country]['default_domain'])


def print_valid_localized_grains():
    results = []
    all_valid_localized_grains = get_all_valid_localized_grains()
    for country, items in all_valid_localized_grains.items():
        results.append('%s' % (country))
    print('\n'.join(results))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter, description='Loads the pillar/valid_custom_grains.py and returns a list of valid custom grains in the form of "country".')
    parser.add_argument('-d', nargs=1, help='Returns a list of the valid domains of a location.')
    parser.add_argument('--default-domain', nargs=1, help='Returns the default domain of a location.')
    args = parser.parse_args()

    if args.d:
        get_all_valid_domains(args.d[0])
    elif args.default_domain:
        get_default_domain(args.default_domain[0])
    else:
        print_valid_localized_grains()

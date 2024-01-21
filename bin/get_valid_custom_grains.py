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


def get_countries():
    return get_valid_custom_grains()['countries']


def print_valid_localized_grains():
    results = []
    for country in get_countries():
        results.append('%s' % (country))
    print('\n'.join(results))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter, description='Loads the pillar/valid_custom_grains.py and returns a list of valid custom grains in the form of "country".')
    args = parser.parse_args()

    print_valid_localized_grains()

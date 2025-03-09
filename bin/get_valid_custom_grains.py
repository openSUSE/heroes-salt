#!/usr/bin/python3

# For description and usage, see the argparse options at the end of the file

import argparse

import yaml


def get_valid_custom_grains():
    with open('pillar/valid_custom_grains.yaml', 'r') as f:
        VALID_CUSTOM_GRAINS = yaml.safe_load(f)

    return VALID_CUSTOM_GRAINS

def get_valid_sites():
    return get_valid_custom_grains()['site']

if __name__ == "__main__":
    parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter, description='Loads and prints pillar/valid_custom_grains.yaml.')
    parser.add_argument('-s', '--sites', action='store_true', help='Only print valid sites.')
    args = parser.parse_args()

    if args.sites:
      print('\n'.join(get_valid_sites()))
    else:
      print(get_valid_custom_grains())

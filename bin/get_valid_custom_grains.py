#!/usr/bin/python3

# For description and usage, see the argparse options at the end of the file

import argparse

import yaml


def get_valid_custom_grains():
    with open('pillar/valid_custom_grains.yaml', 'r') as f:
        VALID_CUSTOM_GRAINS = yaml.safe_load(f)

    return VALID_CUSTOM_GRAINS


if __name__ == "__main__":
    parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter, description='Loads the pillar/valid_custom_grains.py and returns a list of valid custom grains in the form of "site".')
    args = parser.parse_args()

    print(get_valid_custom_grains())

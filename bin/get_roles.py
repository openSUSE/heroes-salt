#!/usr/bin/python3

# For description and usage, see the argparse options at the end of the file

import argparse
import yaml
import os


def get_roles(with_base=False):
    roles = []
    if with_base:
        roles.append('base')

    for sls in os.listdir('pillar/id'):
        with open("pillar/id/%s" % sls) as f:
            try:
                _roles = yaml.load(f)['grains']['roles']
            except KeyError:
                continue
            for item in _roles:
                roles.append(item)

    roles = sorted(set(roles))
    return roles


def print_roles():
    parser = argparse.ArgumentParser('Collects all the roles that are assigned to a minion, and returns them as a python array, a yaml list or a plain list (parsable by bash)')
    parser.add_argument('-p', '--python', action='store_true', help='Prints the roles as a python array')
    parser.add_argument('-y', '--yaml', action='store_true', help='Prints the roles as a yaml array')
    parser.add_argument('--with-base', action='store_true', help='Include the base role at the results')
    args = parser.parse_args()

    roles = get_roles(with_base=args.with_base)
    if args.python:
        print(roles)
    elif args.yaml:
        print('roles:')
        for role in roles:
            print('  - %s' % role)
    else:
        print(' '.join(roles))


if __name__ == "__main__":
    print_roles()

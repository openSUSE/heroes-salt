#!/usr/bin/python3

# For description and usage, see the argparse options at the end of the file

import argparse
import yaml
import os

def read_file_skip_jinja(filename):
    ''' reads a file and returns its content, except lines starting with '{%' '''
    non_jinja_lines = []

    with open(filename) as f:
        for line in f.read().split('\n'):
            if not line.startswith('{%'):
                non_jinja_lines.append(line)

    return '\n'.join(non_jinja_lines)


def get_roles(with_base=False):
    roles = []
    if with_base:
        roles.append('base')

    for sls in os.listdir('pillar/id'):
        content = read_file_skip_jinja("pillar/id/%s" % sls)

        try:
            _roles = yaml.load(content)['grains']['roles']
        except KeyError:
            continue
        for item in _roles:
            roles.append(item)

    roles = sorted(set(roles))
    return roles


def print_roles():
    parser = argparse.ArgumentParser('Collects all the roles that are assigned to a minion, and returns them as a python array, a yaml list or a plain list (parsable by bash)')
    parser.add_argument('-o', '--out', choices=['bash', 'python', 'yaml'], help='Select different output format. Options: bash (default), python, yaml')
    parser.add_argument('-b', '--with-base', action='store_true', default=False, help='Include the base role at the results')
    args = parser.parse_args()

    roles = get_roles(with_base=args.with_base)
    if args.out == 'python':
        print(roles)
    elif args.out == 'yaml':
        print('roles:')
        for role in roles:
            print('  - %s' % role)
    else:
        print(' '.join(roles))


if __name__ == "__main__":
    print_roles()

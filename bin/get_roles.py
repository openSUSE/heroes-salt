#!/usr/bin/python3

# For description and usage, see the argparse options at the end of the file

from copy import copy
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


def get_roles_of_one_minion(minion):
    content = read_file_skip_jinja("pillar/id/%s" % minion)
    try:
        roles = yaml.safe_load(content)['grains']['roles']
    except KeyError:
        roles = []

    return roles


def get_roles(append=[]):
    roles = copy(append)

    for sls in os.listdir('pillar/id'):
        if sls == 'README.md':
            continue

        _roles = get_roles_of_one_minion(sls)
        for item in _roles:
            roles.append(item)

    roles = sorted(set(roles))
    return roles


def print_roles():
    parser = argparse.ArgumentParser('Collects all the roles that are assigned to a minion, and returns them as a python array, a yaml list or a plain list (parsable by bash)')
    parser.add_argument('-o', '--out', choices=['bash', 'python', 'yaml'], help='Select different output format. Options: bash (default), python, yaml')
    parser.add_argument('-a', '--append', action='append', nargs='+', help='Append a list of given roles at the results.')
    args = parser.parse_args()

    appended = []
    if args.append:
        for sublist in args.append:
            for item in sublist:
                appended.append(item)
    roles = get_roles(append=appended)
    if args.out == 'python':
        print(roles)
    elif args.out == 'yaml':
        print(yaml.dump({'roles': roles}, default_flow_style=False))
    else:
        print('\n'.join(roles))


if __name__ == "__main__":
    print_roles()

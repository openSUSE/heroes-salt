#!/usr/bin/python3

# For description and usage, see the argparse options at the end of the file

import argparse
import os
from sys import exit

import yaml


def read_file_skip_jinja(filename):
    ''' reads a file and returns its content, except lines starting with '{%' '''
    non_jinja_lines = []

    with open(filename) as f:
        for line in f.read().split('\n'):
            if not ('{%' in line or '{{' in line or '{#' in line):
                non_jinja_lines.append(line)

    return '\n'.join(non_jinja_lines)


def get_roles_of_one_minion(minion):
    if not minion.endswith('.sls'):
      if '.' not in minion and '_' not in minion:
        minion = f'{minion}.infra.opensuse.org'
      minion = minion.replace('.', '_') + '.sls'
    file = f'pillar/id/{minion}'
    try:
        content = read_file_skip_jinja(file)
    except FileNotFoundError:
        print(f'File {file} not found.')
        return []
    try:
        roles = yaml.safe_load(content)['roles']
    except KeyError:
        roles = []

    return roles


def get_minions_with_role(role):
    minions = []
    for sls in os.listdir('pillar/id'):
      if sls.endswith('.sls'):
          for item in get_roles_of_one_minion(sls):
              if item == role:
                  minions.append(os.path.splitext(sls)[0].replace('_', '.'))

    return sorted(minions)


def get_roles(with_base=False):
    roles = []

    for sls in os.listdir('pillar/id'):
        if sls == 'README.md':
            continue

        _roles = get_roles_of_one_minion(sls)
        for item in _roles:
            roles.append(item)

    roles = sorted(set(roles))

    if with_base:
      roles = ['base'] + roles

    return roles


def get_roles_including(query):
    """
    Return roles including the specified string in their state SLS file.
    """
    roles = []
    for role in get_roles():
        role2 = role.replace('.', '/')
        file = f'salt/role/{role2}.sls'
        if not os.path.isfile(file):
          file = f'salt/role/{role2}/init.sls'
        role_sls = read_file_skip_jinja(file)
        if query in role_sls:
            roles.append(role)
    return roles


def print_roles():
    parser = argparse.ArgumentParser('Collects all the roles that are assigned to a minion, and returns them as a python array, a yaml list or a plain list (parsable by bash)')
    parser.add_argument('-o', '--out', choices=['bash', 'python', 'yaml'], help='Select different output format. Options: bash (default), python, yaml')
    parser.add_argument('-i', '--including', help='Only print roles including the specified string in their state file.')
    parser.add_argument('-m', '--minion', help='Only print roles assigned to the specified minion.')
    parser.add_argument('-r', '--role', help='Print minions the specified role is assigned to.')
    args = parser.parse_args()

    if args.including and args.minion:
      print('Combining --including and --minion is not supported. But you can send a patch for it. :)')
      exit(1)

    if ( args.including or args.minion ) and args.role:
      print('Combining --role with --including or --minion is not possible.')
      exit(1)

    if args.including:
        roles = get_roles_including(args.including)
    elif args.minion:
        roles = get_roles_of_one_minion(args.minion)
    elif args.role:
        roles = get_minions_with_role(args.role)
    else:
        roles = get_roles()
    if args.out == 'python':
        print(roles)
    elif args.out == 'yaml':
        print(yaml.dump({'roles': roles}, default_flow_style=False))
    else:
        print('\n'.join(roles))


if __name__ == "__main__":
    print_roles()

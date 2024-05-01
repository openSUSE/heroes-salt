#!/usr/bin/python3.11
"""
Script to test openSUSE infrastructure data:
- validate files against their respective JSON schema
- test for duplicates where unique values are expected

Copyright (C) 2023-2024 Georg Pfuetzenreuter <mail+opensuse@georg-pfuetzenreuter.net>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""
# functions in this file use complicated branching, but are not feasible to reformat
# ruff: noqa: PLR0912

import ipaddress
import json
import logging
import sys
from argparse import ArgumentParser
from pathlib import Path

import yaml
from jsonschema import Draft202012Validator, ValidationError
from lib.colors import green, orange, red, reset
from referencing import Registry, Resource

# data we do not have schemas for
excluded_files = [
  'clusters', 'domains', 'nameservers', 'networks',
]
excluded_directories = [
  'alerts',
]

infradir = 'pillar/infra/'
schemadir = f'{infradir}schemas/'
reference = 'draft202012.json'

need_unique = ['ip4', 'ip6', 'pseudo_ip4', 'mac']

infra_data = {}
schemas = {}
lun_mappers = []

format_checker = Draft202012Validator.FORMAT_CHECKER

def has_cidr(instance: str) -> bool:
  if '/' not in instance:
    raise ValueError('Must contain a network mask in CIDR notation')

@format_checker.checks('ipv6_net', (ValueError, ipaddress.AddressValueError))
def is_ipv6_network(instance: object) -> bool:
  if not isinstance(instance, str):
    return False
  has_cidr(instance)
  return bool(ipaddress.IPv6Network(instance, strict=False))

@format_checker.checks('ipv4_net', (ValueError, ipaddress.AddressValueError))
def is_ipv4_network(instance: object) -> bool:
  if not isinstance(instance, str):
    return False
  has_cidr(instance)
  return bool(ipaddress.IPv4Network(instance, strict=False))

@format_checker.checks('ip_net', ValueError)
def is_ip_network(instance: object) -> bool:
  if not isinstance(instance, str):
    return False
  has_cidr(instance)
  return bool(ipaddress.ip_network(instance, strict=False))

def _fail(msg=None):
    if msg is not None:
        log.error(msg)
    sys.exit(1)

def test_schema_meta(data):
    registry = Registry().with_resources(
            [
                ("https://json-schema.org/draft/2020-12/schema", Resource.from_contents(schemas['reference'])),
            ],
    )
    validator = Draft202012Validator(schema=schemas['reference'], registry=registry)
    try:
        if validator.validate(data) is None:
            return True
    except ValidationError as myerror:
        log.error(f'Schema validation failed! Error in {myerror.json_path}:')
        log.error(myerror.message)
    _fail('Failed to validate schema against reference schema.')

def test_schema_entry(entry, entry_config, validator):
  log.debug(f'Validating entry {entry} ... ')

  try:
      result = validator.validate(entry_config)
      if result is None:
          log.debug(f'Entry {entry} is {green}valid{reset}!')
      else:
          log.error('failed, but unable to determine the cause. :(')
  except ValidationError as myerror:
      log.error(f'{red}FAIL!{reset} Error in entry {entry} -> {myerror.json_path}:')
      log.error(myerror.message)
      if myerror.cause is not None:
        log.error(myerror.cause)
      return False

  return True

def test_schema():
    returns = {}

    for schema, schema_data in schemas.items():
        log.info(f'Validating schema "{schema}" against reference schema ...')
        test_schema_meta(schema_data)

    log.debug(f'{orange}Preparing to validate files ...{reset}')
    registry = Registry().with_resources(
            [
                (f'infra/schemas/{schema}', Resource.from_contents(schemas[schema]))
                for schema in schemas
            ],
    )
    validators = {}
    for schema in schemas:
      validators[schema] = Draft202012Validator(schema=schemas[schema], registry=registry, format_checker=format_checker)

    for file, contents in infra_data.items():
      log.info(f'Validating dataset "{file}" ...')

      file_split = file.split('/')
      if '/' in file:
        if file_split[1] in validators:
          file_validator_name = file_split[1]
        else:
          file_validator_name = file_split[0]
      else:
        file_validator_name = file

      if file_validator_name not in validators:
        _fail(f'Missing "{file_validator_name}" validator')

      entry_validator_name = file_validator_name.rstrip('s')

      if entry_validator_name not in validators:
        _fail(f'Missing "{entry_validator_name}" validator')

      try:
          validators[file_validator_name].validate(contents)
      except ValidationError as myerror:
          log.error(f'{red}FAIL!{reset} Error in dataset {file} -> {myerror.json_path}:')
          log.error(myerror.message)
          _fail(f'{red}Invalid{reset} {file} file, aborting.')

      if isinstance(contents, dict):
        for entry, entry_config in contents.items():
            returns[file] = test_schema_entry(entry, entry_config, validators[entry_validator_name])
            if not returns[file]:
              break
      elif isinstance(contents, list):
        for entry in contents:
            returns[file] = test_schema_entry(entry, entry, validators[entry_validator_name])
            if not returns[file]:
              break
      else:
        _fail(f'Unsupported entry format: {entry}')

    return returns

def test_duplicates(data):
    def test_key(key, value):
        if key in need_unique:
            if key not in matches:
                matches.update({key: []})
            matches[key].append(value)

    matches = {}

    for host, host_config in data.items():
        for key, value in host_config.items():
            if isinstance(value, dict):
                for low_key, low_value in value.items():
                    if key == 'disks' and not low_value.endswith(('G', 'GB')):
                        lun_mappers.append(low_value)
                    if isinstance(low_value, (int, str)):
                        test_key(low_key, low_value)
                    elif isinstance(low_value, dict):
                        for low_low_key, low_low_value in low_value.items():
                            test_key(low_low_key, low_low_value)
                    else:
                        _fail(f'Encountered unhandled value type in key {low_key} under host {host}.')
            elif isinstance(value, (int, str)):
                test_key(key, value)
            else:
                _fail(f'Encountered unhandled value type in key {key} under host {host}.')

    unique = {}
    matches['lun_mappers'] = lun_mappers
    need_unique_final = need_unique + ['lun_mappers']

    for need_unique_key in need_unique_final:
        unique.update({need_unique_key:
                       {
                           'seen_values': set(),
                           'duplicate_values': [],
                       },
                    },
        )

    for match_key, match_values in matches.items():
        for match_value in match_values:
            if match_value in unique[match_key]['seen_values']:
                unique[match_key]['duplicate_values'].append(match_value)
            else:
                unique[match_key]['seen_values'].add(match_value)

    found_dupes = False

    for key in need_unique_final:
        dupes = unique[key]['duplicate_values']
        if dupes:
            log.error(f'{red}FAIL!{reset} Duplicate values for key {key}: {dupes}')
            found_dupes = True

    return found_dupes

def main():
    for file in Path(f'{infradir}').glob('**/*.yaml'):
      name = file.stem
      parent = file.parent.name
      if len(file.parents) == 3:
        save_name = name
      elif len(file.parents) > 3:
        save_name = f'{parent}/{name}'
      else:
        _fail('Unhandled repository layout')
      if name not in excluded_files and parent not in excluded_directories:
        with open(f'{file}') as fh:
          try:
            infra_data[save_name] = yaml.safe_load(fh)
          except yaml.scanner.ScannerError:
            _fail(f'Invalid YAML file: {file}')

    for file in Path(f'{schemadir}').glob('*.json'):
      name = file.stem
      if name.startswith('draft'):
        continue
      with open(f'{file}') as fh:
          schemas[name] = json.load(fh)

    checks = {'schema': {}}

    log.debug(f'{orange}Executing schema check ...{reset}')
    for file, result in test_schema().items():
      if result is False:
        checks['schema'] = False
        break

    log.debug(f'{orange}Executing duplicates check ...{reset}')
    if test_duplicates(infra_data['hosts']):
        checks['duplicates'] = False
    else:
        checks['duplicates'] = True

    fail = False
    for check, result in checks.items():
        if result is False:
            log.error(f'Check "{check}" {red}failed{reset}.')
            fail = True

    if fail:
        _fail(f'Infrastructure data is {red}invalid.{reset}')
    log.info(f'{green}Infrastructure data is valid.{reset}')

logging.basicConfig(format='%(message)s')
log = logging.getLogger('test_infra_data')

if __name__ == '__main__':
    argp = ArgumentParser(description='Validate infra/**.yaml files against their JSON schemas')
    argp.add_argument('-v', '--verbose', help='Print verbose output', action='store_const', dest='loglevel', const=logging.DEBUG, default=logging.INFO)
    args = argp.parse_args()
    log.setLevel(args.loglevel)
    main()

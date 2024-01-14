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

import json
import sys
from pathlib import Path

import yaml
from jsonschema import Draft202012Validator, ValidationError
from referencing import Registry, Resource

# files we do not have schemas for
excludes = ['clusters', 'domains', 'nameservers', 'networks']

infradir = 'pillar/infra/'
schemadir = f'{infradir}schemas/'
reference = 'draft202012.json'

need_unique = ['ip4', 'ip6', 'pseudo_ip4', 'mac']

infra_data = {}
schemas = {}
lun_mappers = []

def _fail(msg=None):
    if msg is not None:
        print(msg)
    sys.exit(1)

for file in Path(f'{infradir}').glob('**/*.yaml'):
  name = file.stem
  if len(file.parents) == 3:
    save_name = name
  elif len(file.parents) > 3:
    save_name = f'{file.parent.name}/{name}'
  else:
    _fail('Unhandled repository layout')
  if name not in excludes:
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
        print(f'Schema validation failed! Error in {myerror.json_path}:')
        print(myerror.message)
    _fail('Failed to validate schema against reference schema.')

def test_schema():
    returns = {}

    for schema, schema_data in schemas.items():
        print(f'Validating schema "{schema}" against reference schema ...')
        test_schema_meta(schema_data)

    print('Preparing to validate files ...')
    registry = Registry().with_resources(
            [
                (f'infra/schemas/{schema}', Resource.from_contents(schemas[schema]))
                for schema in schemas
            ],
    )
    validators = {}
    for schema in schemas:
      validators[schema] = Draft202012Validator(schema=schemas[schema], registry=registry)

    for file, contents in infra_data.items():
      print(f'Validating dataset {file} ...')

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
          print(f'Error in {myerror.json_path}:')
          print(myerror.message)
          _fail(f'Invalid {file} file')

      returns[file] = True
      for entry, entry_config in contents.items():
          print(f'Validating entry {entry} ... ', end='')
          try:
              result = validators[entry_validator_name].validate(entry_config)
              if result is None:
                  print('ok!')
              else:
                  print('failed, but unable to determine the cause. :(')
          except ValidationError as myerror:
              print(f'failed! Error in {myerror.json_path}:')
              print(myerror.message)
              returns[file] = False
              break

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
            print(f'FAIL: Duplicate values for key {key}: {dupes}')
            found_dupes = True

    return found_dupes

if __name__ == '__main__':
    checks = {'schema': {}}

    print('Executing schema check ...')
    for file, result in test_schema().items():
      if result is False:
        checks['schema'] = False
        break

    print()
    print('Executing duplicates check ...')
    if test_duplicates(infra_data['hosts']):
        checks['duplicates'] = False
    else:
        checks['duplicates'] = True

    fail = False
    for check, result in checks.items():
        if result is False:
            print()
            print(f'Check "{check}" failed.')
            fail = True

    if fail:
        _fail()
    print()
    print('Infrastructure data is valid.')

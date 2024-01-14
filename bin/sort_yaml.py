#!/usr/bin/python3
"""
Script for sorting YAML files
Copyright (C) 2023 Georg Pfuetzenreuter <mail+opensuse@georg-pfuetzenreuter.net>

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

import sys

import yaml


def _fail(msg):
    print(f'{msg}, bailing out.')
    sys.exit(1)

args = sys.argv
indent = False
if '--indent' in args:
  indent = True
  args.remove('--indent')
  # https://github.com/yaml/pyyaml/issues/234#issuecomment-765894586
  class IndentedDumper(yaml.Dumper):
      def increase_indent(self, flow=False, *args, **kwargs): # noqa FBT002 # boolean is simple enough here
          return super().increase_indent(flow=flow, indentless=False)

if len(args) < 2 or not args[1].endswith('.yaml'):
    _fail('Cannot operate without being passed a YAML file')

files = sys.argv[1:]
out = {}

for file in files:
    try:
        with open(file) as fh:
            data = yaml.safe_load(fh)
    except FileNotFoundError:
        _fail(f'Passed file {file} does not exist')

    if data is None:
        _fail(f'Invalid data in file {file}')

    out.update({file: data})

for file, data in out.items():
    with open(file, 'w') as fh:
        if indent is True:
            yaml.dump(data, fh, explicit_start=True, Dumper=IndentedDumper)
        else:
            yaml.safe_dump(data, fh, explicit_start=True)

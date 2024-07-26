#!/usr/bin/python3
"""
Script to test for Salt profiles not included in any profiles or roles.

Copyright (C) 2024 Georg Pfuetzenreuter <mail+opensuse@georg-pfuetzenreuter.net>

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

from pathlib import Path
from sys import exit

from get_profiles import get_profiles
from lib.colors import red, reset


def test_profiles():
  profiles = set(get_profiles())

  def get_recursive_sls_includes(directory):
    includes = set()

    for file in Path(f'salt/{directory}').rglob('*.sls'):
      with open(file) as fh:
        low_includes = []

        for line in fh:
          line = line.lstrip().rstrip()

          if line and line[0] ==  '-':
            low_includes.append(line.replace('- profile.', ''))

        includes.update(set(low_includes))

    return includes

  all_includes = set()
  for part in ['profile', 'role']:
    all_includes.update(get_recursive_sls_includes(part))

  return sorted(profiles - all_includes)


if __name__ == '__main__':
  result = test_profiles()
  if result:
    print(f'{red}Fail{reset} - the following profiles are not included in any profiles or roles - please delete or include them:')
    print('\n'.join(test_profiles()))
    exit(1)

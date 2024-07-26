#!/usr/bin/python3
"""
Script to collect and print a list of our Salt profiles.

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

from argparse import ArgumentParser
from pathlib import Path


def get_profiles(directory='salt/profile', do_subprofiles=False):  # noqa PLR0912
  profiles = []
  subprofiles = []

  for profile in Path(directory).iterdir():
    suffix = profile.suffix
    if suffix == '.sls' and profile.is_file():
      profiles.append(profile.stem)

    elif not suffix and profile.is_dir():
      if not do_subprofiles:
        subprofiles_low = []

      for profile_low in profile.iterdir():
        if profile_low.is_file():
          if profile_low.name == 'init.sls':
            profiles.append(profile.name)

            if not do_subprofiles:
              break

          elif profile_low.suffix == '.sls':
            subprofile = f'{profile.name}.{profile_low.stem}'

            if do_subprofiles:
              subprofiles.append(subprofile)

            else:
              subprofiles_low.append(subprofile)

        elif not profile_low.suffix and profile_low.is_dir():
          continue

        else:
          raise RuntimeError(f'Invalid subprofile: {profile_low}')

      else:
        # including subprofiles albeit subprofiles not being enabled due to no init.sls
        if not do_subprofiles:
          profiles.extend(subprofiles_low)

    else:
      raise RuntimeError(f'Invalid profile: {profile}')

  if do_subprofiles:
    profiles.extend(subprofiles)

  return profiles

if __name__ == '__main__':
    parser = ArgumentParser('Collects and prints all profiles.')
    parser.add_argument('--subprofiles', action='store_true', help='Always include subprofiles. By default, subprofiles are only considered if no init.sls is present.')
    arguments = parser.parse_args()

    print('\n'.join(get_profiles(do_subprofiles=arguments.subprofiles)))

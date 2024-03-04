"""
Grains module for custom grains used in the openSUSE infrastructure

Author: Georg Pfuetzenreuter <mail+opensuse@georg-pfuetzenreuter.net>

Copyright (C) 2023 openSUSE contributors

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

from platform import python_version_tuple

from salt.modules import file


# https://github.com/saltstack/salt/pull/65751
def check_fc_host():
  grains = {'fc_host': False}
  if file.directory_exists('/sys/class/fc_host'):
    grains['fc_host'] = True
  return grains

def system_python():
  """
  Return the system Python version in a format usable as a prefix when referencing Python module packages
  """
  return {'system_python': 'python' + ''.join(python_version_tuple()[:2])}

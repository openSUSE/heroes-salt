#!/usr/bin/python3
"""
Script for generating a .gitlab-ci.yml drop-in for test_highstate
(can be expanded for other jobs if needed)
Copyright (C) 2023 openSUSE contributors
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

from get_roles import get_roles

from argparse import ArgumentParser
from jinja2 import Template
from pathlib import Path
import sys

outdir = '.gitlab-ci.includes'

argp = ArgumentParser(description='Generate .gitlab-ci.yml include files based on Salt roles')
argp.add_argument('-p', help='Print rendered file', action='store_true')
argp.add_argument('-w', help=f'Write rendered file to {outdir}', action='store_true')
args = argp.parse_args()

if not args.p and not args.w:
  argp.print_help()
  sys.exit(1)

# Render include with role based test_highstate chunks
with open('.gitlab-ci.templates/test_highstate.jinja', 'r') as j2:
  template = Template(j2.read())

rendered = template.render(roles=get_roles())

if args.p:
  print(rendered)

if args.w:
  Path(f'{outdir}').mkdir(exist_ok=True)
  with open(f'{outdir}/test_highstate.yml', 'w') as fh:
    fh.write(rendered)

#!/usr/bin/python3
"""
Script for rending .gitlab-ci.yml drop-ins based on available Salt roles
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

import sys
from argparse import ArgumentParser
from pathlib import Path

from get_roles import get_roles, get_roles_including
from jinja2 import Template

enabled_templates = [
  'highstate',
  'nginx',
]

indir  = '.gitlab-ci.templates'
outdir = '.gitlab-ci.includes'

argp = ArgumentParser(description='Generate .gitlab-ci.yml include files based on Salt roles')
argp.add_argument('-p', help='Print rendered file', action='store_true')
argp.add_argument('-w', help=f'Write rendered file to {outdir}', action='store_true')
args = argp.parse_args()

if not args.p and not args.w:
  argp.print_help()
  sys.exit(1)

template = {}
render = {}

for entry in enabled_templates:
  with open(f'{indir}/test_{entry}.jinja', 'r') as j2:
    template[entry] = Template(j2.read())

  if entry == 'highstate':
    render[entry] = template[entry].render(roles=get_roles(with_base=True))
  else:
    render[entry] = template[entry].render(roles=get_roles_including(entry))

  if args.p:
    print(render[entry])

  if args.w:
    Path(f'{outdir}').mkdir(exist_ok=True)
    with open(f'{outdir}/test_{entry}.yml', 'w') as fh:
      fh.write(render[entry])

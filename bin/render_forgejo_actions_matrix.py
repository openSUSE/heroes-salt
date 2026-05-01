#!/usr/bin/python3

from json import dumps
from os import getenv

from get_roles import get_roles, get_roles_including

enabled_types  = [
  'highstate',

  'apache',
  'nginx',
]

out = {}

for entry in enabled_types:
  if entry == 'highstate':
    out[entry] = get_roles(with_base=True)
  else:
    out[entry] = get_roles_including(entry)

outfile = getenv('FORGEJO_OUTPUT')

out = 'role_matrix=' + dumps(out)

if outfile is None:
  print(out)
else:
  with open(outfile, 'w') as fh:
    fh.write(out)

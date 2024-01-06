#!/usr/bin/env python3

# Copyright (c) 2019 Karol Babioch <karol@babioch.de>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import argparse
import logging
import os
import re
import subprocess
import sys

# TODO Add instructions and mention that this needs to be run by someone with access, etc.
# TODO Proper error handling, since this is only a prototype
# TODO Docstrings
# TODO Multithreading ...

RE_PGP_MESSAGE = r'[ \t]*-----BEGIN PGP MESSAGE-----[ \t]*$\n.+?\n^[ \t]*-----END PGP MESSAGE-----[ \t]*$'
RE_PGP_RECIPIENT = r'^0x\w+'
RE_INDENT = r'^(\s*)'

class DecryptError(Exception):
    pass

class EncryptError(Exception):
    pass

def gpg(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE):
    gpg_bin = '/usr/bin/gpg'
    cmd = [gpg_bin] + cmd
    logger.debug('Running: %s', cmd)
    return subprocess.Popen(cmd, stdin=stdin, stdout=stdout, stderr=stderr, encoding=sys.getdefaultencoding())

def decrypt(message):
    cmd = gpg(['--batch', '-d'])
    logger.debug(f'in: {message}')
    out, err = cmd.communicate(message)
    logger.debug(f'return: {cmd.returncode}, out: {out}, err: {err}')
    if cmd.returncode != 0:
        raise DecryptError(err)
    return out

def encrypt(message, recipients):
    cmd = ['--batch', '--yes', '--trust-model', 'always', '--armor', '-e']
    for r in recipients:
        cmd += ['--recipient', r]
    cmd = gpg(cmd)
    logger.debug(f'in: {message}')
    out, err = cmd.communicate(message)
    logger.debug(f'return: {cmd.returncode}, out: {out}, err: {err}')
    if cmd.returncode != 0:
        raise EncryptError(err)
    return out

def reencrypt(message, recipients):
    indent = get_indent(message)
    message = remove_indent(message)
    message = decrypt(message)
    message = encrypt(message, recipients)
    message = add_indent(message, indent)
    return message

def get_indent(block):
    return re.match(RE_INDENT, block.splitlines()[0]).group(1)

def remove_indent(block):
    return '\n'.join([ line.lstrip() for line in block.splitlines() ])

def add_indent(block, indent):
    return '\n'.join([ indent + line for line in block.splitlines() ])

def get_recipients(file):
    with open(file) as f:
        regexp = re.compile(RE_PGP_RECIPIENT, re.MULTILINE)
        recipients = re.findall(regexp, f.read())
        logger.debug(f'recipients: {recipients}')
        return recipients

# Initialize logging
logger = logging.getLogger(__name__)
logger.addHandler(logging.StreamHandler())

# Parse command line arguments
parser = argparse.ArgumentParser(description='Reencrypts pillar data with current list of recipients')
parser.add_argument('-v', '--verbose', dest='verbose', help='Increase verbosity', action='count', default=0)
parser.add_argument('-r', '--recursive', dest='recursive', help='Recursively look for pillar data', action='store_true')
parser.add_argument('--recipients-file', dest='recipients_file', help='File containing list of recipients', default='encrypted_pillar_recipients')
parser.add_argument('pillars', metavar='PILLAR', type=str, nargs='+', help='Pillar file(s)')
args = parser.parse_args()

# Enable logging if debug flag set
if args.verbose == 1:
    logger.setLevel(logging.INFO)
elif args.verbose == 2:
    logger.setLevel(logging.DEBUG)

logger.debug(f'args: {args}')

# Final list of pillars to reencrypt
pillars = []

# List of recipients parsed from file
recipients = get_recipients(args.recipients_file)

# Recursively scan for all pillar files
if args.recursive:
    for pillar in args.pillars:
        for dirpath, dirname, filename in os.walk(pillar):
            for name in filename:
                pillars.append(os.path.join(dirpath, name))
# Only consider what has been provided by user (i.e. non-recursive mode)
else:
    pillars = args.pillars

# Log final list of pillar files
logger.debug(f'pillars: {pillars}')

# Track number of touched pillar files
total = 0
success = 0
failure = 0

# Iterate over all pillar files
for pillar in pillars:

    total += 1

    # Read data from pillar file
    file = open(pillar)
    data = file.read()
    file.close()

    # Search for PGP messages and reencrypt them
    try:
        data, count = re.subn(RE_PGP_MESSAGE, lambda x: reencrypt(x.group(0), recipients), data, flags=re.DOTALL|re.MULTILINE)
    except DecryptError:
        logger.error(f'Failed to decrypt data in file: {pillar}, skipping')
        failure += 1
        continue

    # File was modified, re-write it
    if count > 0:
        file = open(pillar, 'w')
        file.write(data)
        file.close()
        logger.info(f'Successfully reencrypted all data in file: {pillar}')
        success += 1

print(f'total: {total}, skipped: {total - success - failure}, successful: {success}, failed: {failure}')

if failure > 0:
    sys.exit(1)

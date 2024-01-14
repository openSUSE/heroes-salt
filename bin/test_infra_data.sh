#!/bin/bash
# Script to validate openSUSE infrastructure data
# Copyright (C) 2023 Georg Pfuetzenreuter <mail+opensuse@georg-pfuetzenreuter.net>
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
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

set -Cu

INFRADIR='pillar/infra/'

echo 'test_infra_data --> Validating ...'
bin/test_infra_data.py
RESULT_SCHEMA="$?"
echo

echo 'test_infra_data --> Sorting ...'
FIND_ARGS=(
    '-type' 'f'
)
FIND_ARGS_UNSORTED=(
    "${FIND_ARGS[@]}" '-a' '('
    '-wholename' 'pillar/infra/certificates/*.yaml'
    '-o'
    '-wholename' 'pillar/infra/hosts.yaml'
    ')' '-a'
    '-not' '-name' '*.yaml.sorted.yaml'
)
FIND_ARGS_SORTED=(
    "${FIND_ARGS[@]}"
    '-name' '*.yaml.sorted.yaml'
)
find "$INFRADIR" "${FIND_ARGS_UNSORTED[@]}" -exec cp {} {}.sorted.yaml \;
find "$INFRADIR" "${FIND_ARGS_SORTED[@]}"   -exec bin/sort_yaml.py --indent {} +
find "$INFRADIR" "${FIND_ARGS_UNSORTED[@]}" -print0 | xargs -I! -0n1 diff -q ! !.sorted.yaml
RESULT_SORT="$?"
find "$INFRADIR" "${FIND_ARGS_SORTED[@]}"   -delete
echo

echo "test_infra_data --> SCHEMA -> $RESULT_SCHEMA, SORT -> $RESULT_SORT"

if [ "$RESULT_SCHEMA" = 0 ] && [ "$RESULT_SORT" = 0 ]
then
	exit 0
elif [ "$RESULT_SORT" = 123 ]
then
	echo 'Please run bin/sort_yaml.py against the YAML files you modified and amend your commit.'
fi

exit 1

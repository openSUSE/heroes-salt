#!/bin/sh
# Script to lint and validate openSUSE infrastructure data
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

echo 'test_infra_data --> Linting ...'
yamllint -s "$INFRADIR"*.yaml
RESULT_YAML="$?"
echo

echo 'test_infra_data --> Validating ...'
bin/test_infra_data.py
RESULT_SCHEMA="$?"
echo

echo 'test_infra_data --> Sorting ...'
#find "$INFRADIR" -type f -name '*.yaml' -exec cp {} {}.original \;
#bin/sort_yaml.py "$INFRADIR"*.yaml
#find "$INFRADIR" -type f -name '*.yaml' -print0 | xargs -I! -0n1 diff -q ! !.original
cp "$INFRADIR"hosts.yaml "$INFRADIR"hosts.sorted.yaml
bin/sort_yaml.py "$INFRADIR"hosts.sorted.yaml
diff -u "$INFRADIR"hosts.yaml "$INFRADIR"hosts.sorted.yaml
RESULT_SORT="$?"
rm "$INFRADIR"hosts.sorted.yaml
echo

echo "test_infra_data --> Results: YAML -> $RESULT_YAML, SCHEMA -> $RESULT_SCHEMA, SORT -> $RESULT_SORT"

if [ "$RESULT_YAML" == 0 -a "$RESULT_SCHEMA" == 0 -a "$RESULT_SORT" == 0 ]
then
	exit 0
elif [ "$RESULT_SORT" == 1 ] # 123 in case of xargs
then
	echo 'Please run bin/sort_yaml.py against the YAML files you modified and amend your commit.'
fi

exit 1

#!/bin/bash
# Script to lint and style check our code
# Copyright (C) 2024 Georg Pfuetzenreuter <mail+opensuse@georg-pfuetzenreuter.net>
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

set -Cfu
EXIT=0

. bin/get_colors.sh

echo_INFO 'Linting Jinja files ...'
# j2lint does not support passing exclusions through a configuration file
j2lint_args=(
  jinja-statements-delimiter    # allow for {%- (with the hyphen for reduced empty lines)
  jinja-statements-indentation  # allow for custom indentation
  jinja-variable-lower-case     # https://github.com/aristanetworks/j2lint/issues/85 (should be removed when a solution is found)
  operator-enclosed-by-spaces   # allow for "foo|bar" without spaces
  jinja-statements-no-tabs      # false positive in configuration templates using tabs
  single-statement-per-line     # allow for multiple statements in one line: {%- foo -%}{%- bar -%}
)
find . -not -path ./salt/files/\* -type f \( -name '*.j2' -o -name '*.jinja' \) \
  -exec j2lint -i "${j2lint_args[@]}" -- {} +
STATUS_JINJA="$?"
j2lint_args+=(
  single-statement-per-line    # false positive in Libvirt XML templates
)
find salt/files -type f \( -name '*.j2' -o -name '*.jinja' \) \
  -exec j2lint -i "${j2lint_args[@]}" -- {} +
STATUS_JINJA="$?"


echo_INFO 'Linting Python files ...'
ruff check --config etc/ruff.toml .
STATUS_PYTHON="$?"


echo_INFO 'Linting Python files in profiles ...'
TMP_PY="$(mktemp -dp /dev/shm)" || exit 1
export TMP_PY
find salt/profile -type f -name '*.py' \
  -exec sh -c '
    FILE="$1"
    DIR="$(dirname $FILE)"
    mkdir -p "$TMP_PY/$DIR"
    grep -Ev "{(%|{|#)" "$FILE" > "$TMP_PY/$FILE"
    ' x {} \;
pushd "$TMP_PY" >/dev/null || EXIT=1
ruff check --config "$OLDPWD"/etc/ruff.toml .
STATUS_PYTHON_PROFILE="$?"
popd >/dev/null || EXIT=1
rm -r "$TMP_PY"


echo_INFO 'Linting Shell files ...'
# TODO: Include all optional suggestions, except for require-double-brackets and require-variable-braces (-o all -e SC2250,SC2292)
find . -not -path ./t/\* -type f -name '*.sh' \
  -exec shellcheck --rcfile etc/shellcheckrc -x {} +
STATUS_SHELL="$?"


echo_INFO 'Linting SLS files ...'
find . -type f -name '*.sls' \
  -exec salt-lint -c etc/salt-lint.yaml {} +
STATUS_SLS="$?"


echo_INFO 'Linting YAML files ...'
find pillar/ salt/files/ -type f \( -name '*.yaml' -o -name '*.yml' \) \
  -exec yamllint {} +
STATUS_YAML="$?"


echo_INFO 'Checking for trailing whitespaces ...'
STATUS_TWS=0
while read file
do
  tws_found=0
  # we have some files with CRLF line endings ...
  tws_findings="$(dos2unix -O -q "$file" | grep --color=always -n '\s$')" && tws_found=1
  if [ "$tws_found" = 1 ]
  then
    printf 'Lines with trailing whitespace in file %s:\n%s\n\n' "$file" "$tws_findings"
    STATUS_TWS=1
  fi
done < <(find . -not -path './.git/*' -not -path './.ruff_cache/*' -not -name '*.pyc' -type f)


echo
echo '==================='
echo '===== SUMMARY ====='
echo '==================='
echo

if [ "$STATUS_JINJA" = 1 ]
then
  echo '--> Jinja: FAIL'
  echo 'Please check the suggested Jinja formatting changes. Note that these are suggestions, and not all cases are considered. If the implementation of a particular suggestion is unreasonable, please discuss whether the rule should be added to the ignore list.'
  EXIT=5
else
  echo '--> Jinja: PASS'
fi
echo

if [ "$STATUS_PYTHON" = 1 ] || [ "$STATUS_PYTHON_PROFILE" = 1 ]
then
  echo '--> Python: FAIL'
  echo 'Please reformat the problematic Python files to follow the PEP 8 style guide.'
  echo 'Reference: https://peps.python.org/pep-0008/.'
  echo 'Explanations for the linter rule codes: https://docs.astral.sh/ruff/rules/.'
  # shellcheck disable=SC2016
  echo 'Tip: Install `ruff` on your workstation, and use `ruff --fix --unsafe-fixes <file1> <file2> ...` to have the tool automatically implement some of its suggestions.'
  EXIT=5
else
  echo '--> Python: PASS'
fi
echo

if [ "$STATUS_SHELL" = 1 ]
then
  echo '--> Shell: FAIL'
  echo 'Please try to apply the ShellCheck suggestions. Note that the Shebang is used to determine which suggestions should be applied.'
  echo 'If a particular suggestion is not implementable, a comment based override should be declared before the problematic line.'
  EXIT=5
else
  echo '--> Shell: PASS'
fi
echo

if [ "$STATUS_SLS" = 1 ]
then
  echo '--> SLS: FAIL'
  echo 'Please check and apply the salt-lint suggestions.'
  EXIT=5
else
  echo '--> SLS: PASS'
fi
echo

if [ "$STATUS_YAML" = 1 ]
then
  echo '--> YAML: FAIL'
  echo 'Please check and apply the yamllint suggestions.'
  echo 'In most cases, these should be very reasonable and easy to implement. In rare cases where it is not feasible, a comment based exclude in the line before the problematic one can be placed. This however is not possible for files run through sort_yaml.py.'
  EXIT=5
else
  echo '--> YAML: PASS'
fi
echo

if [ "$STATUS_TWS" = 1 ]
then
  echo '--> TRAILING WHITESPACE: FAIL'
  echo 'Please remove useless trailing spaces from the files/lines listed above.'
  EXIT=5
else
  echo '--> TRAILING WHITESPACE: PASS'
fi

if [ "$EXIT" = 5 ]
then
  echo 'Please check the linter suggestions mentioned above and contribute to a common coding style. Thank you!'
elif [ "$EXIT" = 1 ]
then
  echo 'Execution error.'
fi

exit "$EXIT"

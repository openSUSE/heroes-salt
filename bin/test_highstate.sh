#!/bin/bash

# Validate that a highstate works for all roles
# Takes the role name as an argument

set -u
role="$1"

[[ $(whoami) == 'root' ]] || { echo 'Please run this script as root'; exit 1; }

# sysctl: cannot stat /proc/sys/net/core/netdev_max_backlog (and some other /proc files): No such file or directory
( cd /sbin/ || exit 1 ; ln -sf /usr/bin/true sysctl )

source bin/get_colors.sh

test/setup/master_minion

IDFILE="pillar/id/$HOSTNAME.sls"

out="$role.txt"
echo "START OF $role" > "$out"

echo_INFO "Testing role: $role"

printf 'roles:\n- %s' "$role" >> "$IDFILE"

if [ -x "test/setup/role/$role" ]
then
  echo "Preparing test environment for role $role ..." >> "$out"
  "test/setup/role/$role"
fi

salt --out-file=cli.txt --out-file-append "$HOSTNAME" saltutil.refresh_pillar

salt-call --out-file="$out" --out-file-append --retcode-passthrough --state-output=full --output-diff state.apply test=True
rolestatus=$?
echo >> "$out"

if test $rolestatus = 0; then
    echo_PASSED
else
    echo_FAILED
fi
echo

echo "END OF $role" >> "$out"

mkdir system

# "log_granular_levels" is a thing, but regex is easier here
# lines matching PATTERNS will be stripped from the log files
PATTERNS=(
  '/Marking .* as a jinja (filter|global|test)/'
  '/The functions from module .* are/'
  '/MasterEvent (PUB|PULL) socket URI/'
  '/(Missing|Reading) configuration/'
  '/Using cached minion ID/'
  '/Override  __(grains|utils)__/'
  '/dmidecode/'
  '/Grains refresh requested/'
  '/LazyLoad/'
  '/Loading static grains from/'
  '/Authentication (request|accepted)/'
  '/Worker binding to socket/'
  '/Creating master /'
  '/ReqServer (clients|worker)/'
  '/Started .* with pid/'
)
PATTERNS=( "${PATTERNS[@]/%/||}" '/^xxx$/' )

filter_log () {
  perl -ne "print unless ${PATTERNS[*]}" "$1" > "$2"
}

filter_log /var/log/salt/minion system/minion_log.txt
filter_log /var/log/salt/master system/master_log.txt
mv cli.txt system

salt "$HOSTNAME" pillar.items > pillar.txt

mkdir render
render_log='render/_log.txt'
render_failures=( $(gawk 'match($0, /Rendering SLS '\''base:(.*)'\'' failed/, capture) { gsub(/\./, "/", capture[1]); print "salt/" capture[1] ".sls" }' system/minion_log.txt) )

if [ -n "${render_failures[*]}" ]
then
  {
    echo 'State files failed to render:'
    echo "${render_failures[*]}"
    echo
  } | tee -a "$render_log"
  for state in "${render_failures[@]}"
  do
    echo "Processing: $state" | tee -a "$render_log"
    state_path="$PWD/$state"
    # state rendering logic is pointless, as we operate on states which failed rendering before
    # leaving for future reference
    #state_out_dir="render/$(dirname "$state")"
    #state_out_file="render/$state.txt"
    #echo "Rendering: $state" | tee -a "$render_log"
    #if [ ! -d "$state_out_dir" ]
    #then
    #  mkdir -pv "$state_out_dir" >> "$render_log"
    #fi
    #salt-call --out-file="$state_out_file" slsutil.renderer "$state_path" default_renderer=jinja
    pillar_references=( $(awk '$0 !~ /pillar\.get/{ next } /pillar\.get/match($0, /\(['\''|"]([[:alnum:]_:]+)['\''|"]/, capture) { printf capture[1] }' "$state_path") )
    if [ -n "${pillar_references[*]}" ]
    then
      pillar_files=()
      for pillar in "${pillar_references[@]}"
      do
        pillar_lines+=( ${pillar//:/ } ) 

        while read file
        do
          for line in "${pillar_lines[@]}"
          do
            grep -q "$line" "$file" || continue 2
          done
          pillar_files+=("$file")
        done < <(find pillar -type f -name '*.sls')
      done
      {
        echo
        echo 'Possibly related pillar files:'
        echo "${pillar_files[*]}"
        echo
      } | tee -a "$render_log"
      mkdir work
      for pillar_file in "${pillar_files[@]}"
      do
        echo "Processing: $pillar_file" | tee -a "$render_log"
        # traversing directories in the GitLab artifact browser is annoying, hence replacing slashes with underscores
        pillar_out_file="render/${pillar_file//\//_}.txt"
        if [ -f "$pillar_out_file" ]
        then
          echo "File $pillar_file already rendered." >> "$render_log"
        else
          echo "Rendering: $pillar_file" | tee -a "$render_log"
          # https://github.com/saltstack/salt/issues/51835#issuecomment-1536442278
          perl -pe \
            's/(?<BEGIN>\{%-? )(?:(?<PRE>from ["'\''])(?<PATH>.*)(?<POST1>["'\''] import )(?<POST2>[\w\s]+)|(?<PRE>import_yaml ["'\''])(?<PATH>.*)(?<POST1>["'\''] ?.*? as \w+))(?<END> -?%\})$/$+{BEGIN}$+{PRE}\/srv\/pillar\/$+{PATH}$+{POST1}$+{POST2}$+{END}/' \
            "$pillar_file" > work/this
          grep srv work/this >> "$render_log"
          salt-call --out-file="$pillar_out_file" slsutil.renderer "$PWD/work/this" default_renderer=jinja
          rm work/this
        fi
        echo >> "$render_log"
      done
    fi
  done
else
  echo 'No render failures found (this is probably a good thing!)' > "$render_log"
fi

echo
echo 'Output and logs can be found in the job artifacts!'
exit $rolestatus

# vim:expandtab

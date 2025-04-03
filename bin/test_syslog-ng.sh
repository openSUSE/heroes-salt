#!/bin/sh
# Script to test our syslog-ng configuration
# Applies the profile.log.syslog-ng.{client,server} states and runs the native config tests
#
# Copyright (C) 2025 Georg Pfuetzenreuter <mail+opensuse@georg-pfuetzenreuter.net>
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
set -Cefu

. bin/lib/systemctl.sh

loglevel='info'
logbase_syslog='log_syslog'
logbase_salt='log_salt'
outbase_salt='out_salt'

salt () {
	salt-call --local -lcritical --log-file="$1" --log-file-level="$loglevel" --out-file="$2" --out-file-append --retcode-passthrough state."$3" "$4"
}

check_config () {
	logfile="$1"
	if ! mispipe 'syslog-ng --no-caps -s' "tee -a $logfile"
	then
		echo 'Configuration is invalid' | tee -a "$logfile"
		return 1
	fi
	return 0
}

run () {
	# tests:
	#   1. the client setup with only our common client pillar
	#   2. the server setup with its server specific pillar
	#   3. the client setup with the server specific pillar (role will still be set from the prior loop iteration)
	for profile in log.syslog-ng.client log.syslog-ng.server log.syslog-ng.client
	do
		printf 'Testing profile %s ...\n' "$profile"
		if [ "$profile" = 'profile.log.syslog-ng.server' ]
		then
			echo 'Adding server role ...'
			printf 'roles:\n- logger\n' >> "$IDFILE"
		fi
		logfile_syslog="${logbase_syslog}_${profile}.txt"
		if [ -f "$logfile_syslog" ]
		then
			logfile_syslog="${logbase_syslog}_${profile}_2.txt"
			logfile_salt="${logbase_salt}_${profile}_2.txt"
			outfile_salt="${outbase_salt}_${profile}_2.txt"
		else
			logfile_salt="${logbase_salt}_${profile}.txt"
			outfile_salt="${outbase_salt}_${profile}.txt"
		fi
		echo "Start of $logfile_syslog" > "$logfile_syslog"
		echo "Start of $logfile_salt" > "$logfile_salt"
		if ! salt "$logfile_salt" "$outfile_salt" show_sls profile."$profile"
		then
			echo 'State is faulty, not proceeding to test syslog-ng.' | tee -a "$logfile_salt" "$logfile_syslog"
			exit 1
		fi
		if ! salt "$logfile_salt" "$outfile_salt" apply profile."$profile"
		then
			echo 'State apply failed, not proceeding to test syslog-ng.' | tee -a "$logfile_salt" "$logfile_syslog"
			exit 1
		fi
		check_config "$logfile_syslog"
	done
}

if ! { command -v salt-call && command -v syslog-ng ; } 1>/dev/null
then
	# shellcheck disable=SC2016
	echo 'This script needs `salt-call` and `syslog-ng` - aborting.'
	exit 1
fi

IDFILE="pillar/id/$(hostname).sls"
run

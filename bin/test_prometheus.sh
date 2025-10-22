#!/bin/sh
# Script to test our Prometheus and Alertmanager configuration
# Applies the monitoring.* roles and runs the native config tests
#
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
set -Cefu

. bin/lib/systemctl.sh

loglevel='info'
logbase_prometheus='log_prometheus'
logbase_salt='log_salt'
outbase_salt='out_salt'

salt () {
	salt-call --local -lcritical --log-file="$1" --log-file-level="$loglevel" --out-file="$2" --out-file-append --retcode-passthrough state."$3" "$4"
}

hack_pillar () {
	# use a documentation address for this to work in containers with an empty fqdn_ip6
	sed -i "s/grains\['fqdn_ip6'\]\[0\]/'2001:0DB8::100'/" pillar/role/monitoring/alertmanager.sls pillar/role/monitoring/master.sls
	cp pillar/role/monitoring/master.sls pillar_role_monitoring_master.sls.txt
	# inject a pillar containing a structure that would usually be found in the mine of a production minion, we reference this in
	# profile.monitoring.prometheus.targets as no real mine data is available in the test environment
	# to generate:
	# - salt --out=json --out-file=/tmp/monitor.mine monitor.infra.opensuse.org mine.get tgt='*' fun="['grains', 'roles', 'states']"
	# - sed -Ei 's/^(		)"monitor.infra.opensuse.org"(: \{)/\1"fake_mine"\2/' /tmp/monitor.mine
	cp test/pillar/monitor_mine.sls pillar/
	sed '/^include:/a\\  - monitor_mine' pillar/role/monitoring/master.sls
}

gen_ssl () {
	sls='pillar/role/monitoring/master.sls'
	awk '/SSLCertificateFile:/{ print $2 }' "$sls" | while read certificate
	do
		mkdir -p "$(dirname "$certificate")"
		cp test/fixtures/domain.crt "$certificate"
	done
	awk '/SSLCertificateKeyFile:/{ print $2 }' "$sls" | while read key
	do
		mkdir -p "$(dirname "$key")"
		cp test/fixtures/domain.key "$key"
	done
}

check_prometheus () {
	logfile="$1"
	if ! mispipe 'promtool check config --lint-fatal /etc/prometheus/prometheus.yml' "tee -a $logfile"
	then
		echo 'Configuration is invalid' | tee -a "$logfile"
		return 1
	fi
	return 0
}

check_alertmanager () {
	logfile="$1"
	if ! mispipe 'amtool check-config /etc/prometheus/alertmanager.yml' "tee -a $logfile"
	then
		echo 'Configuration is invalid' | tee -a "$logfile"
		return 1
	fi
	return 0
}

check_rules_files () {
	find salt/files/prometheus/alerts -type f -name '*.yaml' > rule_files || return 1
	while read file
	do
		file="$(basename "$file")"
		if ! test -f /etc/prometheus/rules/"${file%.yaml}.yml"
		then
			echo "Missing file: $file!"
			return 1
		fi
	done < rule_files
}

run () {
	for role in monitoring.master monitoring.alertmanager
	do
		printf 'Testing role %s ...\n' "$role"
		printf 'roles:\n- %s\n' "$role" >> "$IDFILE"
		logfile_prometheus="${logbase_prometheus}_${role}.txt"
		logfile_salt="${logbase_salt}_${role}.txt"
		outfile_salt="${outbase_salt}_${role}.txt"
		echo "Start of $logfile_prometheus" > "$logfile_prometheus"
		echo "Start of $logfile_salt" > "$logfile_salt"
		if ! salt "$logfile_salt" "$outfile_salt" show_sls role."$role"
		then
			echo 'State is faulty, not proceeding to test Prometheus.' | tee -a "$logfile_salt" "$logfile_prometheus"
			exit 1
		fi
		if ! salt "$logfile_salt" "$outfile_salt" apply role."$role"
		then
			echo 'State apply failed, not proceeding to test Prometheus.' | tee -a "$logfile_salt" "$logfile_prometheus"
			exit 1
		fi
		if [ "$role" = 'monitoring.master' ]
		then
			mkdir "rules"
			find /etc/prometheus/rules -type f -name '*.yml' -exec sh -c 'cp "$1" "rules"/"$(basename "$1")".txt' x {} \;
			cp /etc/prometheus/prometheus.yml "prometheus".yml.txt
			check_rules_files
			check_prometheus "$logfile_prometheus"
		elif [ "$role" = 'monitoring.alertmanager' ]
		then
			cp /etc/prometheus/alertmanager.yml "alertmanager".yml.txt
			check_alertmanager "$logfile_prometheus"
		fi
		cp "$IDFILE".orig "$IDFILE"
	done
}

if ! { command -v amtool && command -v promtool && command -v salt-call ; } 1>/dev/null
then
	# shellcheck disable=SC2016
	echo 'This script needs `amtool`, `promtool`, `salt-call` - aborting.'
	exit 1
fi

IDFILE="pillar/id/$(hostname).sls"
cp "$IDFILE" "$IDFILE".orig
hack_pillar
gen_ssl
run

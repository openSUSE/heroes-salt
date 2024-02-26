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

# have service.* states work in containers without an init system
( cd /usr/bin/ || exit 1 ; ln -fs true systemctl )

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
	# replace mine call, avoid using a master based test container here
	# (pillar rendering with mine functionality is tested during test_highstate anyways)
	sed -i "s/= salt.saltutil.runner.*/= {'roles': {'minion-with-monitoring-master-role': ['monitoring.master'], 'minion-with-mariadb-1': ['mariadb'], 'minion-with-mariadb-2': ['mariadb']}, 'grains': {'minion-kvm-1': {'fqdn': 'kvm-minion-1.infra.opensuse.org', 'virtual': 'kvm'}, 'minion-with-kvm-2': {'fqdn': 'kvm-minion-2.infra.opensuse.org', 'virtual': 'kvm'}, 'physical.infra.opensuse.org': {'fqdn': 'physical-fqdn.infra.opensuse.org', 'virtual': 'physical'}}} %}/" pillar/role/monitoring/master.sls
	cp pillar/role/monitoring/master.sls pillar_role_monitoring_master.sls.txt
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
	if ! mispipe 'promtool check config /etc/prometheus/prometheus.yml' "tee -a $logfile"
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
	find pillar/infra/alerts -type f -name '*.yaml' | while read file
	do
		file="$(basename "$file")"
		if ! test -f /etc/prometheus/rules/"${file%.yaml}.yml"
		then
			echo "Missing file: $file!"
			return 1
		fi
	done
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

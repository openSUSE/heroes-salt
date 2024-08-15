#!/bin/bash -Ce
#{{ pillar['managed_by_salt'] }}
# Copyright (C) 2024 openSUSE contributors
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

# This script is intended to be called by galera1:/usr/local/sbin/backup_replica_sync.sh.

DB_USER='mybackup-replicator'
DB_PASS='{{ salt['pillar.get']('profile:mariadb:users:mybackup-replicator') }}'
BEGIN_SECONDS=$(date +%s)

# /usr/local/sbin/backup_replica_restore.sh -d /var/lib/mysql-files/backup/backup-20210212 -f galera1.infra.opensuse.org -l master-bin.000773 -p 2760687
usage (){
		echo
		echo "usage: $0 -d <backup directory> -l <master bin filename> -p <log position>"
		echo '			 -d = path to the backup (should be a directory populated by mariabackup)'
		echo '			 -f = the master FQDN'
		echo '			 -l = the master-bin file name'
		echo '			 -p = the log-position inside the master-bin filename'
		echo
		echo '			 -h = this help'
		echo
}

if [ "$1" ]; then
		if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
			usage
			exit 0
		fi
		while getopts 'hd:f:l:p:'  OPTION ; do
				case $OPTION in
					d)	BACKUP="$OPTARG"
						;;
					f)	DB_MASTERHOST="$OPTARG"
						;;
					l)	MASTER_FILENAME="$OPTARG"
						;;
					p)	MASTER_LOG_POS="$OPTARG"
						;;
					*)	usage
						exit 1
						;;
				esac
		done
		shift $(( OPTIND - 1 ))
else
		usage
		exit 1
fi

if [ ! -d "$BACKUP" ]; then
		echo "ERROR: Could not find a directory at $BACKUP" >&2
		exit 1
fi
if [ -z "$MASTER_FILENAME" ]; then
		echo 'ERROR: Please provide a valid master-bin filename' >&2
		exit 1
fi
if [ -z "$MASTER_LOG_POS" ]; then
		echo 'ERROR: Please provide a valid log position' >&2
		exit 1
fi

set -u

if [ -S '/run/mysql/mysql.sock' ]
then
		echo 'Stopping synchronization with master node'
		mariadb -e 'STOP SLAVE; RESET SLAVE;'
fi

echo 'Stopping MariaDB'
systemctl stop mariadb

echo 'Deleting data'
rm -fr /var/lib/mysql/*

echo 'Installing backup'
mariadb-backup --copy-back --target-dir="$BACKUP"
ls /var/lib/mysql
chown -R mysql: /var/lib/mysql

echo 'Starting MariaDB'
systemctl start mariadb

echo 'Configuring slave'
mariadb -e "CHANGE MASTER TO MASTER_HOST='$DB_MASTERHOST',MASTER_PORT=3306,MASTER_USER='$DB_USER',MASTER_PASSWORD='$DB_PASS',MASTER_LOG_FILE='$MASTER_FILENAME',MASTER_LOG_POS=$MASTER_LOG_POS;"

echo "Starting slave"
mariadb -e "START SLAVE;"

END_SECONDS="$(date +%s)"
RUNTIME_RAW_SECONDS=$((END_SECONDS-BEGIN_SECONDS))
RUNTIME_HOURS=$((RUNTIME_RAW_SECONDS/3600))
RUNTIME_MINUTES=$(($((RUNTIME_RAW_SECONDS%3600))/60))
RUNTIME_SECONDS=$(($((RUNTIME_RAW_SECONDS%3600))%60))
echo "Restoring backup finished. Duration (hh:mm:ss): $RUNTIME_HOURS:$RUNTIME_MINUTES:$RUNTIME_SECONDS"

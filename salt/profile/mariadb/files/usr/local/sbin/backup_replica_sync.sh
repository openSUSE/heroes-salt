#!/bin/bash -efu
# shellcheck disable=SC2155  # only for local file/date variables
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

LOGFILE="/var/log/$(basename "$0").log"
BACKUP_CLIENT='mybackup.infra.opensuse.org'
DEBUG='yes'

HOST="$(hostname -s)"
FQDN="$(hostname -f)"
SMS=$(mktemp /tmp/master_status.XXXXXX)
BEGIN_SECONDS=$(date +%s)
DATE=$(date "+%Y%m%d")

LOG(){
		local MESSAGE="$1"
		local LOGDIR=$(dirname "$LOGFILE")
		local LOG_DATE=$(date "+%b %d %H:%M:%S")
		if [ -z "$LOGFILE" ]; then
				echo "ERROR:	 function LOG needs a defined LOGFILE variable" >&2
				exit 1
		fi
		if [ -z "$LOGNAME" ]; then
				LOGNAME=$(basename "$0")
		fi
		if [ ! -d "$LOGDIR" ]; then
				mkdir -p "$LOGDIR" || exit 1
				echo "$LOG_DATE $HOST $LOGNAME: function LOG created $LOGDIR" > "$LOGFILE"
		fi
		echo "$LOG_DATE $HOST $LOGNAME: $MESSAGE" >> "$LOGFILE"
		if [ "$DEBUG" = "yes" ]; then
				echo "DEBUG:		$MESSAGE"
		fi
}

LOG "Starting at $(date)"

#
# Dump databases
#
SOURCE_BACKUP="/var/lib/mysql-files/backup/${DATE}"

if [ -d "$SOURCE_BACKUP" ]
then
		LOG 'Deleting earlier backup'
		rm -r "$SOURCE_BACKUP"
fi

LOG "Dumping all databases to $SOURCE_BACKUP"
mariadb-backup --backup --open-files-limit=5000 --target-dir="$SOURCE_BACKUP"
LOG 'Dump is ready'

# shellcheck disable=SC2034  # we do not use GTID, only in read call for splitting
read BINLOG_FILE BINLOG_POSITION GTID_POSITION < "$SOURCE_BACKUP"/mariadb_backup_binlog_info
LOG "Logfile: $BINLOG_FILE ; current position: $BINLOG_POSITION"

#
# Prepare backup
#
LOG "Preparing backup"
mariadb-backup --prepare --target-dir="$SOURCE_BACKUP"
LOG 'Backup is ready'

#
# Transfer dump to slave
#
TARGET_BACKUP="/backup/bootstrap/${DATE}"

LOG "Starting transfer to $BACKUP_CLIENT"
rsync -a -e'ssh -q' --info=progress2 "$SOURCE_BACKUP"/ "$BACKUP_CLIENT":"$TARGET_BACKUP"
LOG 'Transfer completed'

#
# Resetting slave
#
LOG "Calling backup_replica_restore.sh on $BACKUP_CLIENT"
ssh -q $BACKUP_CLIENT "/usr/local/sbin/backup_replica_restore.sh -f $FQDN -d $TARGET_BACKUP -l $BINLOG_FILE -p $BINLOG_POSITION"
LOG -n 'Remote execution returned'
BACKUP_STATE=$(ssh $BACKUP_CLIENT "mariadb -e 'show slave STATUS\G;' | grep Running | grep -v Slave_SQL_Running_State")
LOG "$BACKUP_STATE"

#
# Cleanup
#
LOG 'Cleaning up ...'
rm "$SMS"
rm -r "$SOURCE_BACKUP"
LOG "Finished at $(date)"

#
# Print local status
#
mariadb -e "SHOW MASTER STATUS;"
mariadb -e "SHOW STATUS LIKE '%wsrep%';"

#
# Print statistics
#
END_SECONDS="$(date +%s)"
RUNTIME_RAW_SECONDS=$((END_SECONDS-BEGIN_SECONDS))
RUNTIME_HOURS=$((RUNTIME_RAW_SECONDS/3600))
RUNTIME_MINUTES=$(($((RUNTIME_RAW_SECONDS%3600))/60))
RUNTIME_SECONDS=$(($((RUNTIME_RAW_SECONDS%3600))%60))
LOG "Preparing $BACKUP_CLIENT finished. Duration (hh:mm:ss): $RUNTIME_HOURS:$RUNTIME_MINUTES:$RUNTIME_SECONDS"

echo 'OK'

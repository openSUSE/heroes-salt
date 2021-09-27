#!/bin/bash
# [[ $(whoami) == 'root' ]] || { echo 'Please run this script as root'; exit 1; }

sudo logrotate --debug /etc/logrotate.conf
if [ "$?" != 0 ]; then
	echo 
	echo "There is an error in one or more logrotate snipplets" >&2
    echo
    exit 1
fi

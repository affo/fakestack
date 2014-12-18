#!/bin/bash
# force reclone of the service given in $1

if [[ $EUID -eq 0 ]]; then
	echo "You are running this script as root."
	echo "Run as $STACK_USER, please."
	exit 1
fi

if [ $# -eq 0 ]; then
	echo "Give service name, please."
	exit 1
fi

# clean everything
/devstack/clean.sh
# remove $1 folder
rm -rf /opt/stack/$1
# reinstall (only nova)
/devstack/stack.sh

echo "$1 reinstalled succesfully!"
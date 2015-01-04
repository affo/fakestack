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

# prevent apt-get to give problems...
# badass way...
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock

# clean everything
/devstack/clean.sh
echo "   ---> DevStack cleaned!"
# remove $1 folder
rm -rf /opt/stack/$1
echo "   --> $1 folder removed!"
# ensure that mysql and rabbit are up
# (on compute nodes these commands will fail).
sudo service mysql start
sudo service rabbitmq-server start
# reinstall (only $1)
/devstack/stack.sh
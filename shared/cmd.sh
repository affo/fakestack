#!/bin/bash

function start_service {
	if [ -f "/etc/init.d/$1" ]; then
		#the service is there
		sudo service $1 start
	fi
}

CTRL_IP=42.42.255.254/16
if [ $(hostname) = "controller" ]; then
	# we are in the controller:
	# change ip
	sudo ifconfig eth0 $CTRL_IP
	echo "controller: eth0 IP set to $CTRL_IP"
fi

start_service mysql
start_service rabbitmq-server
su stack -c '/devstack/stack.sh'
#!/bin/bash

function start_service {
	if [ -f "/etc/init.d/$1" ]; then
		#the service is there
		sudo service $1 start
	fi
}

start_service mysql
start_service rabbitmq-server
su stack -c '/devstack/stack.sh'
#!/bin/bash

function start_service {
	if [ -f "/etc/init.d/$1" ]; then
		#the service is there
		sudo service $1 start
	else
		echo "Cannot start $1: the service is not installed"
	fi
}

# editing /etc/hosts for rabbit and openstack
sudo sh -c "echo '127.0.0.1 localhost' > /etc/hosts"
sudo sh -c "echo '42.42.255.254 controller' >> /etc/hosts"

CTRL_IP=42.42.255.254/16
GW_IP=42.42.0.1
if [ $(hostname) = "controller" ]; then
	# we are in the controller:
	# change ip
	sudo ifconfig eth0 $CTRL_IP
	echo "controller: eth0 IP set to $CTRL_IP"
	sudo route add default gw $GW_IP eth0
	echo "default gateway set to $GW_IP"
else
	my_ip=$(ifconfig  | grep 'inet addr:'| grep '42.42.*' | cut -d: -f2 | awk '{ print $1}')
	sudo sh -c "echo '$my_ip $(hostname)' >> /etc/hosts"
fi

echo "--> /etc/hosts edited!"
echo "--> cat /etc/hosts:"
cat /etc/hosts

# test connection with Google's DNS
echo "checking connection..."
check_connection=$(ping -c 3 8.8.8.8)
if [ -z "$check_connection" ]; then
	echo "something went wrong in configuring connection..."
	exit 1
else
	echo "connection OK."
fi

# update devstack
su stack -c 'git -C /devstack fetch official'
su stack -c 'git -C /devstack rebase official/master'
su stack -c 'git -C /devstack pull origin master'

start_service mysql
start_service rabbitmq-server
su stack -c '/devstack/stack.sh'
# change escape sequencwe
stty intr \^k
echo "To KILL the process press CTRL-K"
# run shell to stay on
sudo su stack
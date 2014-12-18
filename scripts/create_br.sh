#!/bin/bash
CIDR=42.42.0.1/16

if [ $# -eq 0 ]; then
	echo "./create_br.sh <bridge_name>"
	echo "This script will create a bridge named as <bridge_name>"
	echo "with CIDR $CIDR, using brctl (sudo apt-get install bridge-utils)"
	exit 1
fi

check=$(ip addr show $1)
if [ ! -z "$check" ]; then
	# the bridge inserted already exists
	echo "The bridge inserted already exists"
	exit 1
fi

echo "Now sudoing. Insert your password please..."

sudo service docker stop
check=$(ip addr show docker0)
if [ ! -z "$check" ]; then
	# this means docker0 exists
	sudo ip link set dev docker0 down
	sudo brctl delbr docker0
fi

sudo brctl addbr $1
sudo ip addr add $CIDR dev $1
sudo ip link set dev $1 up
sudo service docker start

echo "Bridge $1 created! Remember to add it do DOCKER_OPTS in /etc/default/docker"
echo 'e.g. DOCKER_OPTS="-b <bridge_name>"'
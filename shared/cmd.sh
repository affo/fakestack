#!/bin/bash

FIREBASE_BASE_URL='https://adock.firebaseio.com'
NODE_TYPE='cmp'
IP=$(ifconfig  | grep 'inet addr:'| grep '42.42.*' | cut -d: -f2 | awk '{ print $1}')

function start_service {
	if [ -f "/etc/init.d/$1" ]; then
		#the service is there
		sudo service $1 start
	else
		echo "Cannot start $1: the service is not installed"
	fi
}

function post_usage {
	i=0
	avg_cpu=0
	avg_ram=0
	for i in {1..10} do
		sleep 1
		cpu=$(mpstat | awk 'FNR == 4 {print $3}')
		total=$(cat /proc/meminfo | awk '/MemTotal/ {print $2}')
		free=$(cat /proc/meminfo | awk '/MemFree/ {print $2}')
		used=$(($total - $free))
		i=$(($i + 1))
		avg_cpu=$(bc <<< 'scale = 5; ($avg_cpu + $cpu) / $i')
		avg_ram=$(bc <<< 'scale = 5; ($avg_ram + $used) / $i')
	done

	data='{"cpu": '$avg_cpu', "ram: "'$avg_ram'}'
	curl -X PUT -d $data $FIREBASE_BASE_URL'/'$IP'/usage/'$(date +"%m_%d_%Y__%H_%S")'.json'
}

if [ $(hostname) = "controller" ]; then
	NODE_TYPE='ctrl'

# test connection with Google's DNS
echo "checking connection..."
check_connection=$(ping -c 3 8.8.8.8)
if [ -z "$check_connection" ]; then
	echo "something went wrong in configuring connection..."
	exit 1
else
	echo "connection OK."
fi

start_service mysql
start_service rabbitmq-server
# get the time of stack.sh execution
EXECUTION_TIME=$(TIMEFORMAT='%R'; (time su stack -c '/devstack/stack.sh') 2>&1 | awk 'END{print $1}')
# post it on firebase
curl -X PUT -d '{"time_s": '$EXECUTION_TIME'}' $FIREBASE_BASE_URL'/stack_sh/'$NODE_TYPE'/'$(date +"%m_%d_%Y__%H_%S")'.json'
post_usage()
# change escape sequence
stty intr \^k
echo "To KILL the process press CTRL-K"
# run shell to stay on
sudo su stack
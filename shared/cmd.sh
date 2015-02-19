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

function post_data {
	echo 'Retrieving usage data...'
	i=0
	avg_cpu=0
	avg_ram=0
	ram_total=$(cat /proc/meminfo | awk '/MemTotal/ {print $2}')
	for i in {1..10}; do
		cpu=$(mpstat | awk 'FNR == 4 {print $3}')
		ram_free=$(cat /proc/meminfo | awk '/MemFree/ {print $2}')
		ram_used=$(($ram_total - $ram_free))
		i=$(($i + 1))
		avg_cpu=$(bc <<< 'scale = 5; ($avg_cpu + $cpu) / $i')
		avg_ram=$(bc <<< 'scale = 5; ($avg_ram + $ram_used) / $i')
		sleep 1
	done

	ram_perc=$(bc <<< 'scale = 5; $avg_ram / $ram_total')
	data='{"cpu_r_used": '$avg_cpu', "ram_r_used: "'$ram_perc'}'
	curl -X PUT -d $data $FIREBASE_BASE_URL'/'$IP'/usage/'$(date +"%m_%d_%Y__%H_%S")'.json'
}

######### cmd
echo 'installing mpstat...'
sudo apt-get install -y sysstat

if [ $(hostname) = "controller" ]; then
	NODE_TYPE='ctrl'
fi

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
# calculate execution time
start=$(date +%s)
su stack -c '/devstack/stack.sh'
end=$(date +%s)
ex_time=$(($start-$end))
#post it
data='{"time_s": '$ex_time'}'
curl -X PUT -d '$data' $FIREBASE_BASE_URL'/stack_sh/'$NODE_TYPE'/'$(date +"%m_%d_%Y__%H_%S")'.json'
post_data
# change escape sequence
stty intr \^k
echo "To KILL the process press CTRL-K"
# run shell to stay on
sudo su stack

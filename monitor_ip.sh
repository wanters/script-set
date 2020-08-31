#!/bin/bash

monitor_log="/home/root/monitor_ip.log"
monitor_log_max_size=200000

while true
do
	if [[ ! -f $monitor_log ]]
	then
		cd /home/root
		touch $monitor_log
	fi
	#查看是否有eth0网卡
	net_card=`ifconfig | grep eth0 | awk '{print $1}'`
	if [[ $net_card == "eth0" ]]
	then
#		echo "eth0 is up" >> $monitor_log 
		net_ip=`ifconfig eth0 | grep "inet addr" | cut -f 2 -d ":" | cut -f 1 -d " "`
#		echo "current ip is "$net_ip >> $monitor_log
		net_ip_first=`echo $net_ip | cut -f 1 -d "."`
#		echo "current ip first number is "$net_ip_first >> $monitor_log
		if [[ $net_ip_first == "169" ]]
		then
			echo `date +%Y-%m-%d/%T` >> $monitor_log
			echo "current ip is "$net_ip >> $monitor_log
			echo "networking restart" >> $monitor_log
			/etc/init.d/networking restart
		fi
		if [[ $net_ip == "" ]]
		then
			echo `date +%Y-%m-%d/%T` >> $monitor_log
			echo "current ip is null"$net_ip >> $monitor_log
			echo "networking restart" >> $monitor_log
			/etc/init.d/networking restart
		fi
		sleep 10
	fi

	log_size=`ls $monitor_log -l | cut -f 5 -d " "`
#	echo "log size $log_size"
	if [[ $log_size -gt $monitor_log_max_size ]]
	then
#		echo "clear monitor log"
		echo "" > $monitor_log
	fi
done


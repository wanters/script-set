#!/bin/bash 

while true
do
	procnum=`ps -aux | grep thttpd | grep -v grep | wc -l`
	if [ $procnum -eq 0 ]; then
		/home/root/thttpd_ing/sbin-arm/thttpd -C /home/root/thttpd_ing/thttpd.conf &
	fi
	sleep 10
done

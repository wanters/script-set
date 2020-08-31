#!/bin/sh
INTERVAL=3600

NTPCMD="/usr/sbin/ntpdate -su"
NTPURL=ntp.ntsc.ac.cn


while :
do
    $NTPCMD $NTPURL
    if [ $? -eq 0 ];then
        hwclock -w
        sleep $INTERVAL
    else
        sleep 10 
    fi
done

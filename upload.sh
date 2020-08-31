#!/bin/bash

COLOR='\e[32;1m'; ERROR='\e[31;1m'; NORMAL='\e[0m'
upload_file=dev_mod
dest_ip=60

if [ $# -eq 0 ];then
	echo "Upload default file to default ip"
else
	if [ $# -eq 1 ];then
		upload_file=$1
	elif [ $# -eq 2 ];then
		upload_file=$1
		dest_ip=$2
	fi
fi

echo -e "Upload file is $COLOR $upload_file $NORMAL"
echo -e "Dest ip is $COLOR $dest_ip $NORMAL"

scp $upload_file root@192.168.1.$dest_ip:/home/root

if [ $? -eq 0 ];then
	echo -e "${COLOR}Upload file success ${NORMAL}"
else
	echo -e "${ERROR}Upload file fail ${NORMAL}"
fi

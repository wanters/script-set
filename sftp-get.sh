#!/bin/bash

echo "get file from server, start..."
#login username 
USER=ztf
#login ip
IP=192.168.1.33
#Go to the remote specified path
REMOTEDIR=server_path
#Save to the local path
LOCALPATH=client_path
#Get file name
FILE_NAME=file_name


sftp ${USER}@${IP} << EOF
	cd  ${REMOTEDIR}
	lcd ${LOCALPATH}
	get ${FILE_NAME}
	quit
EOF

echo "get file from server, finish..."



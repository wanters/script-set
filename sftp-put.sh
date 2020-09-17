#!/bin/bash
echo "put file to server, start..."
#login username 
USER=ztf
#login ip
IP=192.168.1.33
#Go to the remote specified path
REMOTEDIR=server_path
#Save to the local path
LOCALPATH=client_path
#Put file name
FILE_NAME=file_name

sftp ${USER}@${IP} << EOF
	cd  ${REMOTEDIR}
	lcd ${LOCALPATH}
	put ${FILE_NAME}
	quit
EOF

echo "put file to server, finish..."



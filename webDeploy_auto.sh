#!/bin/bash -e

COLOR='\e[32;1m'
ERROR='\e[31;1m'
NORMAL='\e[0m'

COLOR_E='\e\[32;1m'
ERROR_E='\e\[31;1m'
NORMAL_E='\e\[0m'

password="bhky"
deviceUserName="root"
deviceIP="192.168.1.66"
deviceAppPath="/home/${deviceUserName}/webServer"
deviceAppScriptPath="/home/${deviceUserName}/webServer"
deviceAppScript="/home/${deviceUserName}/webServer/webserver"
linkScript="webserver"
appPath="./归档"
#remotePath="https://bhky-pc/svn/电子车牌读写器/固定式读写器/过程库/软件/WEB/归档"
remotePath="https://192.168.1.110:443/svn/电子车牌读写器/固定式读写器/过程库/软件/WEB/归档"
copyPath="./归档/烧写文件/webServer"
watchdogAppName="watchdog_ward"

devicePass="bhky"
svnUser="--username zhengtengfei --password 123456"

# [1]确定目标设备ip
if [ $# -eq 0 ];then
	echo -e "${COLOR}[1] Start config device[${deviceIP}] ${NORMAL}"
else
	if [ $# -eq 1 ];then
		deviceIP=$1
		echo -e "${COLOR}[1] Start config device[${deviceIP}] ${NORMAL}"
	else
		echo -e "${ERROR}[1] Parameter error ${NORMAL}"
		exit 0
	fi
fi

# [2] 从服务器[svn]拉取最新版本应用[thttpd,看门狗,ip监控和启动脚本]
# 2.1.如果没有checkout应用，首先checkout一下
if [ ! -e "$appPath" ]; then
	echo -e "${COLOR}[2][1] Checkout app to local${NORMAL}"
	svn checkout ${svnUser} "$remotePath"
fi
# 2.2.更新应用[update]
cd ${appPath}
echo -e "${COLOR}[2][2] Update local app${NORMAL}"
echo -e "${COLOR}[2][3] PWD is `pwd`${NORMAL}"
svn update ${svnUser}
cd ..
echo -e "${COLOR}[2][4] PWD is `pwd`${NORMAL}"

# [3] 停止目标设备上对应的应用[看门狗开启后,无法停止]
# 注:一定要写在一行上,且注意转义
sendCmd="if \[ -e ${deviceAppScriptPath} \];then if \[ -e ${deviceAppScript} \];then ${deviceAppScript} stop; else echo -e '${ERROR_E}${deviceAppScript} no exist${NORMAL_E}'; fi; else echo -e '${ERROR_E}${deviceAppScriptPath} no exist${NORMAL_E}'; fi"

echo -e "${COLOR}[3][1] Stop device app${NORMAL}"
expect <<-EOF
	set timeout 2
	spawn ssh ${deviceUserName}@${deviceIP} "${sendCmd}"
	expect {
		"*password:" { send "${password}\n";exp_continue } 
		"yes/no" { send "yes\n";exp_continue }
		"#" { send "exit\n";exp_continue }
	}
EOF
### TODO 完善expect返回值,当错误时,直接退出
if [ $? -eq 0 ];then
	echo -e "${COLOR}[3][2] Stop app success${NORMAL}"
else
	echo -e "${ERROR}[3][2] Stop app fail${NORMAL}"
	exit 0
fi

# [4] 拷贝webServer到目标设备
echo -e "${COLOR}[4][1] Copy app to device start${NORMAL}"
expect <<-EOF
	set timeout -1
	spawn scp -r ${copyPath} ${deviceUserName}@${deviceIP}:/home/${deviceUserName}/
	expect {
		"*password:" { send "${password}\n";exp_continue } 
		"yes/no" { send "yes\n";exp_continue }
		"#" { send "exit $?\n"; }
	}
EOF
# 查看拷贝结果
if [ $? -eq 0 ];then
	echo -e "${COLOR}[4][2] Copy app to device success${NORMAL}"
else
	echo -e "${ERROR}[4][3] Copy app to device error${NORMAL}"
	exit 0
fi

# [5] 由于看门狗不能停止,所以更新时需要修改软链
# TODO 如果将看门狗停下更好
echo -e "${COLOR}[5][1] Add watchdog softlink start${NORMAL}"
# 5.1 找到看门狗程序
watchdogApp=`find ${copyPath} -name ${watchdogAppName}*`
if [ "${watchdogApp}" = "" ];then
	echo -e "${ERROR}[5][2] ${watchdogAppName} no exist ${NORMAL}"
	exit 0;
fi
echo -e "${COLOR}[5][3] watchdogApp is [${watchdogApp}]${NORMAL}"
watchdogApp=`basename ${watchdogApp}`
echo -e "${COLOR}[5][4] ${watchdogApp}${NORMAL}"
# 5.2.创建软链
expect <<-EOF
	set timeout 2
	spawn ssh ${deviceUserName}@${deviceIP} "ln -sb ${deviceAppScriptPath}/${watchdogApp} ${deviceAppScriptPath}/${watchdogAppName}"
	expect {
		"*password:" { send "${password}\n";exp_continue } 
		"yes/no" { send "yes\n";exp_continue }
		"#" { send "exit\n"; }
	}
EOF
echo -e "${COLOR}[5][5] Add watchdog softlink end${NORMAL}"

# [6] 部署到开机启动和重启关闭中
# 由于update-rc.d只支持为/etc/init.d下的脚本创建启动/重启链接,所以需要为deviceAppScript添加一个软链
# 6.1.创建软链
echo -e "${COLOR}[6][1] Add update-rc.d start/stop${NORMAL}"
expect <<-EOF
	set timeout 2
	spawn ssh ${deviceUserName}@${deviceIP} "ln -sb ${deviceAppScript} /etc/init.d/${linkScript}"
	expect {
		"*password:" { send "${password}\n";exp_continue } 
		"yes/no" { send "yes\n";exp_continue }
		"#" { send "exit\n"; }
	}
EOF
# 6.2.修改启动项
expect <<-EOF
	set timeout 2
	spawn ssh ${deviceUserName}@${deviceIP} "/usr/sbin/update-rc.d ${linkScript} start 20 2 3 4 5 . stop 80 0 1 6 ."
	expect {
		"*password:" { send "${password}\n";exp_continue } 
		"yes/no" { send "yes\n";exp_continue }
		"#" { send "exit\n"; }
	}
EOF
echo -e "${COLOR}[6][2] Add update-rc.d start/stop finish${NORMAL}"

# [7] 重启设备
echo -e "${COLOR}[7] reboot device${NORMAL}"
expect <<-EOF
	set timeout 2
	spawn ssh ${deviceUserName}@${deviceIP} "/sbin/reboot"
	expect {
		"*password:" { send "${password}\n";exp_continue } 
		"yes/no" { send "yes\n";exp_continue }
		"#" { send "exit\n"; }
	}
EOF

# [8] 结束
echo -e "${COLOR}[8] Deploy finish, please confirm${NORMAL}"

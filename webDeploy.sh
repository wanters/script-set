#!/bin/bash 

COLOR='\e[32;1m'
ERROR='\e[31;1m'
NORMAL='\e[0m'

password="bhky"
deviceUserName="root"
deviceIP="192.168.1.66"
deviceAppPath="/home/${deviceUserName}/webServer"
deviceAppScriptPath="/home/${deviceUserName}/webServer"
deviceAppScript="/home/${deviceUserName}/webServer/webserver"
linkScript="webserver"
appPath="./归档"
remotePath="https://bhky-pc/svn/电子车牌读写器/固定式读写器/过程库/软件/WEB/归档"
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
	svn checkout  ${svnUser} "$remotePath"
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
echo -e "${COLOR}[3][1] Stop device app${NORMAL}"
ssh ${deviceUserName}@${deviceIP} "if [ -e ${deviceAppScriptPath} ];then if [ -e ${deviceAppScript} ];then ${deviceAppScript} stop; else echo -e '${ERROR}${deviceAppScript} no exist${NORMAL}'; fi; else echo -e '${ERROR}${deviceAppScriptPath} no exist${NORMAL}'; fi"

test $? -eq 0 || echo -e "${ERROR}[finish] $0 fail ${NORMAL}";exit 0

# [4] 拷贝webServer到目标设备
echo -e "${COLOR}[4][1] Copy app to device start${NORMAL}"
scp -r ${copyPath} ${deviceUserName}@${deviceIP}:/home/${deviceUserName}/
# 查看拷贝结果
#if [ $? -eq 0 ];then
#	echo -e "${COLOR}[4][2] Copy app to device success${NORMAL}"
#else
#	echo -e "${ERROR}[4][3] Copy app to device error${NORMAL}"
#	exit 0
#fi

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
ssh ${deviceUserName}@${deviceIP} "ln -sb ${deviceAppScriptPath}/${watchdogApp} ${deviceAppScriptPath}/${watchdogAppName}"

# [6] 部署到开机启动和重启关闭中
# 由于update-rc.d只支持为/etc/init.d下的脚本创建启动/重启链接,所以需要为deviceAppScript添加一个软链
echo -e "${COLOR}[6][1] Add update-rc.d start/stop${NORMAL}"
ssh ${deviceUserName}@${deviceIP} "ln -sb ${deviceAppScript} /etc/init.d/${linkScript}"
ssh ${deviceUserName}@${deviceIP} "/usr/sbin/update-rc.d ${linkScript} start 20 2 3 4 5 . stop 80 0 1 6 ."
echo -e "${COLOR}[6][2] Add update-rc.d start/stop finish${NORMAL}"

# [7] 重启设备
echo -e "${COLOR}[7] reboot device${NORMAL}"
ssh ${deviceUserName}@${deviceIP} "/sbin/reboot"

# [8] 结束
echo -e "${COLOR}[8] Deploy finish, please confirm${NORMAL}"


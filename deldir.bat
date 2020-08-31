@REM #########################################################  
@REM  Name: 递归删除指定的目录，请把此文件放在你希望执行的那个目录  
@REM  Desciption:   
@REM  Author: stephen  
@REM  Date: 2020-08-14
@REM  Version: 1.0  
@REM  Copyright: everyone
@REM #########################################################  
  
@REM 执行命令不打印
@echo off
@REM 开启延时变量
@setlocal enabledelayedexpansion  
@REM 设置你想删除的目录  
set WANT_DELETED_DIR=.svn
@REM 递归删除 
for /r . %%a in (!WANT_DELETED_DIR!) do (  
	if exist %%a (  
		echo remove %%a
		@REM pause
		rmdir /s /q "%%a"  
	)
)  
echo Delete [%WANT_DELETED_DIR%] Finish 
pause
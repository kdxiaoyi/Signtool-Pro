@echo off&goto start
:USERS
::::::用于自定义一些参数

rem tU用于定义时间戳获取网址。必须填写。
set tU=http://ca.signfiles.com/TSAServer.aspx

rem tUb 为备用时间戳地址。不必填写。
set tUb2=http://tsa.starfieldtech.com
set tUb3=http://timestamp.gobalsign.com/scripts/timestamp.dll
set tUb4=
::::::users.sub.end
goto menu.exec.path

:start
title Signtool Pro - SIGN
mode CON: COLS=80 LINES=30
if not exist lib\signtool.exe (
    set lostFile=signtool.exe
    goto lost
)
if not exist lib\prepare.exe (
    set lostFile=prepare.exe
    goto lost
)
::::::因为一些BUG被ban
rem if exist "%1" (
rem    set exec=%1
rem    goto menu.pfx.path
rem )
goto users

:lost
cls
echo ^> 签名文件
echo ===============================================================================
echo.
echo         错误：未能找到文件
echo    File [%LostFile%] has been lost.
echo    请重新全部解压后再试
echo.
echo  Made by kdXiaoyi.
echo ===============================================================================
pause>nul
exit /b 1

:menu.exec.path
cls
set exec=test.exe
echo ^> 签名文件
echo ===============================================================================
echo.
echo         请输入要签名的文件路径。(请带引号)
echo         你也可以将文件拖入本窗口后按回车键。
echo.%1
echo  Made by kdXiaoyi.
echo ===============================================================================
set /p exec=#^> 
if not exist %exec% (
    echo.
    echo 无效路径
    pause>nul
    goto menu.exec.path
)
if exist "%exec%" set exec="%exec%"
goto menu.pfx.path

:menu.pfx.path
cls
echo ^> 签名文件
echo ===============================================================================
echo.
echo         请输入证书路径。(请带引号)
echo         你也可以将文件拖入本窗口后按回车键。
echo.
echo   [!] 将pfx证书放入[cert\]目录下并改名为[sign.pfx]后，这一步将直接跳过。
echo.
echo  Made by kdXiaoyi.
echo ===============================================================================
if exist "CERT\sign.pfx" (
    echo  检测到SIGN证书。
    set pfx=cert\sign.pfx
    goto sign_password
)
set /p pfx=#^> 
if not exist %pfx% (
    echo.
    echo 无效路径
    pause>nul
    goto menu.pfx.path
)
goto sign_password

:sign_password
cls
echo ^> 签名文件
echo ===============================================================================
echo.
echo         正在签名文件……
echo.
echo   [!] 为了保证安全性，您需要验证私钥
echo.
echo  Made by kdXiaoyi.
echo ===============================================================================
rem 提示键入私钥
set /p passwd=键入私钥（没有则留空，显示密码）：
goto sign_sign

:sign_sign
cls
rem 签名时隐藏密码
lib\prepare.exe
set bad=0
cls
echo ^> 签名文件
echo ===============================================================================
echo.
echo         正在签名文件……
echo.
echo   [!] 为了保证安全性，您需要验证私钥
echo.
echo  Made by kdXiaoyi.
echo ===============================================================================
echo 键入私钥（没有则留空，隐藏密码）：******
if "%passwd%"=="" (lib\signtool.exe sign /v /f "%pfx%" %exec%) else (echo 已提供私钥。&lib\signtool.exe sign /p "%passwd%" /v /f "%pfx%" %exec%)
if "%errorlevel%"=="1" (
    rem /// TO DO ///
    echo ===============================================================================
    echo.
    echo         签名失败。请查看输出以寻找错误。
    echo.
    echo ===============================================================================
    pause>nul
    set bad=1
)

rem 加时间戳
lib\signtool timestamp /v /t %tU% %exec%
if "%errorlevel%"=="1" (
    echo ===============================================================================
    echo.
    echo         加盖时间戳（1）失败。请查看输出以寻找错误。
    echo.
    echo ===============================================================================
    pause>nul
) else (
	echo ===============================================================================
	echo.
	echo         时间戳（1）已加盖。
	echo.
	echo ===============================================================================
)
if not "%tUb2%"=="" (
	lib\signtool timestamp /v /t %tUb2% %exec%
	if "%errorlevel%"=="1" (
		echo ===============================================================================
		echo.
		echo         加盖时间戳（2）失败。请查看输出以寻找错误。
		echo.
		echo ===============================================================================
		pause>nul
	) else (
		echo ===============================================================================
		echo.
		echo         时间戳（2）已加盖。
		echo.
		echo ===============================================================================
	)
)
if not "%tUb3%"=="" (
	lib\signtool timestamp /v /t %tUb3% %exec%
	if "%errorlevel%"=="1" (
		echo ===============================================================================
		echo.
		echo         加盖时间戳（3）失败。请查看输出以寻找错误。
		echo.
		echo ===============================================================================
		pause>nul
	) else (
		echo ===============================================================================
		echo.
		echo         时间戳（3）已加盖。
		echo.
		echo ===============================================================================
	)
)
if not "%tUb4%"=="" (
	lib\signtool timestamp /v /t %tUb4% %exec%
	if "%errorlevel%"=="1" (
		echo ===============================================================================
		echo.
		echo         加盖时间戳（4）失败。请查看输出以寻找错误。
		echo.
		echo ===============================================================================
		pause>nul
	) else (
		echo ===============================================================================
		echo.
		echo         时间戳（4）已加盖。
		echo.
		echo ===============================================================================
	)
)

rem 输出结果
if not "%bad%"=="1" (
    echo.
    echo 签名操作已成功执行。
    echo 0=打开文件目录并退出    1=退出向导    2=再签名一个程序
    echo.
) else (
    echo.
    echo.
    echo 未能完成签名操作
    echo 0=打开文件目录并退出    1=退出向导    2=再签名一个程序
    echo.
)
echo ===============================================================================
choice /C 012 /N /M [0/1/2]^> 
if "%errorlevel%"=="1" explorer.exe /select,"%exec%"
if "%errorlevel%"=="3" goto menu.exec.path
exit /b 0
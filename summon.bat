@echo off
title Signtool Pro - SUMMON
mode CON: COLS=80 LINES=30
cls
goto check/main

:check/main
echo ^> 制作一个签名文件
echo ===============================================================================
echo.
echo         正在检查……
echo.
echo  Made by kdXiaoyi.
echo ===============================================================================
timeout /t 3 >nul
if not exist lib\cert2spc.exe (
    set lostFile=cert2spc.exe
    goto check/lost
)
if not exist lib\makecert.exe (
    set lostFile=makecert.exe
    goto check/lost
)
if not exist lib\pvk2pfx.exe (
    set lostFile=pvk2pfx.exe
    goto check/lost
)
if not exist lib\prepare.exe (
    set lostFile=prepare.exe
    goto check/lost
)
goto SUMMON/name

:check/lost
cls
echo ^> 制作一个签名文件
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

:summon/name
lib\prepare.exe
cls
echo ^> 制作一个签名文件
echo ===============================================================================
echo.
echo         请填写证书名
echo.
echo  Made by kdXiaoyi.
echo ===============================================================================
set /p name=#^> 
if "%name%"=="" (
    echo.
    echo 证书名不合法
    pause>nul
    goto summon/name
)
goto summon/creative.iKey.input

:summon/creative.iKey.input
md CERT
cls
rem 私钥填写
echo ^> 制作一个签名文件
echo ===============================================================================
echo.
echo         请填写私钥
echo.
echo   [!] 通常私钥不对外公开，请谨慎保存
echo   [!] 稍后将会多次验证私钥
echo.
echo  Made by kdXiaoyi.
echo ===============================================================================
lib\Makecert.exe -sv cert\PVK.pvk -r -n "CN=%name%" cert\CER.cer
echo Backcode:%errorlevel%
timeout /t 1 >nul
goto summon/creative.spc.out

:summon/creative.spc.out
cls
rem 创建发行者证书
echo ^> 制作一个签名文件
echo ===============================================================================
echo.
echo         创建发行者证书...
echo.
echo.
echo  Made by kdXiaoyi.
echo ===============================================================================
lib\Cert2spc.exe cert\CER.cer cert\SPC.spc
echo Backcode:%errorlevel%
timeout /t 1 >nul
goto summon/creative.pfx.out

:summon/creative.pfx.out
cls
rem 导出PFX证书文件
echo ^> 制作一个签名文件
echo ===============================================================================
echo.
echo         导出PFX证书……
echo.
echo   [!] 为了保证安全性，您需要验证您刚才填写的私钥
echo.
echo  Made by kdXiaoyi.
echo ===============================================================================
lib\pvk2pfx.exe -pvk cert\PVK.pvk -spc cert\SPC.spc -pfx cert\PFX.pfx -f >>nul
echo Backcode:%errorlevel%
timeout /t 1 >nul
goto summon/finish

:summon/finish
cls
echo ^> 制作一个签名文件
echo ===============================================================================
echo.
echo    恭喜! 您已成功制作一个签名文件。
echo.
echo   介绍一下您的签名文件：
echo   CER.cer ^| DER    ^| 不含私钥，仅包括发布者信息和公钥   可以公开
echo   PFX.pfx ^| PKCS12 ^| 包含私钥和公钥以及发布者信息       严禁公开
echo   SPC.spc ^| SPC    ^| 用于保存公钥。   微软独有
echo   PVK.pvk ^| SPC    ^| 用于保存私钥。   微软独有
echo.
echo   [!] 这种自签证书通常不被其他设备信任，需要导入到[受信任的根证书颁发机构]存储库。
echo.
echo  在等待后您将可以结束向导并打开证书目录。
echo.
echo  Made by kdXiaoyi.
echo ===============================================================================
timeout /t 10 /NOBREAK>>nul
echo 你现在可以按下任意键结束向导。
pause>nul
explorer.exe /root,%cd%\cert
exit /b 0
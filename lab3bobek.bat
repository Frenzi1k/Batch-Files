@echo off
setlocal enabledelayedexpansion
break>rezult.txt
for /f "tokens=1,2 delims=:" %%g in ('ipconfig /all ^| findstr /i /c:"IPv4 Address"') do (
	call :print "IPv4 Address:%%h"
)
for /f "tokens=1,2 delims=:" %%g in ('ipconfig /all ^| findstr /i /c:"Subnet Mask"') do (
	call :print "Subnet Mask:%%h"
)
for /f "tokens=1,2 delims=:" %%g in ('ipconfig /all ^| findstr /i /c:"Default Gateway"') do (
	if not "%%h"==" " (
		call :print "Default Gateway:%%h"
	)
)
for /f "skip=2 tokens=5 delims= " %%g in ('getmac /v') do (
	call :print "Physical Address: %%g"
)
for /f "skip=10 tokens=1,2 delims=:" %%g in ('ipconfig /all') do (
	echo %%g | findstr /i /c:"NetBIOS over Tcpip" > nul
	if not errorlevel 1 (
		goto exit	
	)
	echo %%g | findstr /i /c:"DHCP Enabled" > nul
	if not errorlevel 1 (
		call :print "DHCP Enabled:%%h"
	)
	echo %%g | findstr /i /c:"DHCP Server" > nul
	if not errorlevel 1 (
		call :print "DHCP Server:%%h"	
	)
	echo %%g | findstr /i /c:"DHCPv6 IAID" > nul
	if not errorlevel 1 (
		call :print "DHCPv6 IAID:%%h"	
	)
	echo %%g | findstr /i /c:"DHCPv6 Client DUID" > nul
	if not errorlevel 1 (
		call :print "DHCPv6 Client DUID:%%h"	
	)
	echo %%g | findstr /i /c:"DNS Servers" > nul
	if not errorlevel 1 (
		call :print "DNS Servers:%%h"
	)
)
:exit
set "site=www.logitech.com"
call :print "Checking %site%"
for /f "skip=3 tokens=1 delims=" %%g in ('nslookup %site%') do (
	call :print "  %%g"
)
for /f "skip=1 tokens=1 delims=" %%g in ('wmic nic where "NetEnabled=true" get speed') do (
	call :print "Speed: %%g"
	goto exit1
)
:exit1

for /f "skip=4 tokens=1,8 delims= " %%g in ('tracert -h 3 yandex.ru') do (
	if "%%g"=="Trace" (
		call :print "Complete"
	) else (
		call :print "%%g: %%h"
	)
)

for /f "delims=" %%d in ('tracert -w 2 yandex.ru') do (
	call :print "%%d"
)

set avg=0
for /f "skip=4 tokens=1,2,4,6,8 delims= " %%a in ('tracert -w 2 yandex.ru') do (
	set /a avg=%%b+%%c+%%d
	if !avg! GEQ 30 (
		call :print "%%a: %%b-%%c-%%d %%e"
	)
)

for /f "delims=" %%d in ('arp -a') do (
	call :print "%%d"
)

for /f "delims=" %%d in ('netstat -an') do (
	call :print "%%d"
)

set limit=1450
:begin
set /a limit=!limit!+1
for /f "delims=" %%d in ('ping -f -l !limit! yandex.ru') do (
	call :print "%%d"
	@echo %%d | findstr /i c:/"Packet needs to be fragmented but DF set" > nul
	if not errorlevel 1 (
		call :print "Done" 
		goto end
	)
)
goto begin
:end
pause
exit 1

:print
	set str=%1
	set "str=%str:~1,-1%"
	echo %str%
	echo %str%>>rezult.txt
goto:eof
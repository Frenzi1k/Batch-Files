@echo off
setlocal EnableDelayedExpansion
set var count=0
for %%D in (c d e f g h i j k l m n o p q r s t u v w x y z) do (
	%%D:
	cd /d %%D:/
	call :check '!cd!%1'
	if exist "%%D:\" (
		for /d /r %%G in ("*") do (
			echo %%~fG
			call :check '%%~fG\%1'
		)
	)
)
echo %count%
if count == 0 (
	echo I've found nothing.
)
pause

:check
set "str=%~1"
set str=%str:~1,-1%
if exist "!str!" (
	@echo !str!
	start notepad "!str!"
	set /a "count=!count! + 1"
	pause
)
goto :eof